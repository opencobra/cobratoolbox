/*
 * siteSearch.js
 * ~~~~~~~~~~~~~
 *
 * Full-site instant search for the COBRA Toolbox documentation website.
 *
 * Replaces the previous function-name-only easyAutocomplete widget
 * (`_static/json/functions.json`) with a widget that queries three sources:
 *
 *   1. Sphinx's own generated `searchindex.js` "objects" table (MATLAB
 *      functions/classes/methods documented via autodoc) -> kind "function".
 *   2. Sphinx's own generated `searchindex.js` page titles/terms (every other
 *      .rst-generated page: installation, FAQ, guides, contributing,
 *      citations, and the modules/ listing pages themselves) -> kind "doc"
 *      (or "function" when the page itself lives under modules/).
 *   3. A small supplemental JSON index for tutorial pages, produced by
 *      documentation/source/sphinxext/generateTutorialSearchIndex.py, since
 *      tutorials are carried over as pre-built HTML rather than rebuilt from
 *      .rst each publish and are therefore absent from Sphinx's own index
 *      -> kind "tutorial".
 *
 * `searchindex.js` is not JSON: it is a script that calls the global
 * `Search.setIndex(...)` (see Sphinx's own `_static/searchtools.js`, whose
 * `Search`/`Scorer` objects this file requires to already be loaded on the
 * page -- see documentation/source/_templates/searchbox.html, which loads
 * both explicitly, since the sphinx_cobra_theme layout does not). This file
 * reuses Sphinx's own `Search.loadIndex`/`Search._index`/`Scorer` and
 * `splitQuery`/`makeSearchSummary` rather than re-implementing indexing or
 * scoring from scratch (see specs/019-full-site-search/research.md,
 * Decision 1 and its "Open items - resolved during implementation" note).
 */
"use strict";

var SiteSearch = (function () {
  var MIN_QUERY_LENGTH = 2; // guards against noisy single-character queries
  var MAX_RESULTS = 10;
  var DEBOUNCE_MS = 200;
  var SUMMARY_FETCH_LIMIT = 5; // only fetch page HTML for a snippet on the top N results

  var state = {
    siteRoot: "",
    searchIndexUrl: "",
    tutorialsIndexUrl: "",
    tutorials: [], // [{title, url, body_text, kind: "tutorial"}]
    tutorialsLoaded: false,
    input: null,
    resultsBox: null,
    debounceTimer: null,
  };

  function hasSearch() {
    // Sphinx's searchtools.js declares `const Search = {...}` at its own top
    // level: a lexical global, not a `window` property, so `typeof Search`
    // is the only reliable existence check (`window.Search` is always
    // undefined even once searchtools.js has loaded and run).
    return typeof Search !== "undefined";
  }

  function onSearchIndexReady(callback) {
    // Search.loadIndex() injects <script src="searchindex.js"> which, once it
    // executes, calls the real Search.setIndex(...) and sets Search._index.
    // There is no load callback for that, so poll briefly.
    if (hasSearch() && Search.hasIndex && Search.hasIndex()) {
      callback();
      return;
    }
    var attempts = 0;
    var timer = setInterval(function () {
      attempts += 1;
      if (hasSearch() && Search.hasIndex && Search.hasIndex()) {
        clearInterval(timer);
        callback();
      } else if (attempts > 100) {
        // ~10s at 100ms: give up quietly, function/doc results just won't
        // appear until the index does; tutorial-only results still work.
        clearInterval(timer);
      }
    }, 100);
  }

  function loadTutorialsIndex() {
    if (!state.tutorialsIndexUrl) {
      state.tutorialsLoaded = true;
      return;
    }
    fetch(state.tutorialsIndexUrl)
      .then(function (response) {
        if (!response.ok) throw new Error("tutorials index not available");
        return response.json();
      })
      .then(function (data) {
        state.tutorials = Array.isArray(data) ? data : [];
      })
      .catch(function () {
        // No tutorials supplement yet (e.g. a local build that has not run
        // generateTutorialSearchIndex.py) -- degrade gracefully, function
        // and doc results still work.
        state.tutorials = [];
      })
      .finally(function () {
        state.tutorialsLoaded = true;
      });
  }

  function docUrl(docname, anchor) {
    var suffix =
      (window.DOCUMENTATION_OPTIONS && DOCUMENTATION_OPTIONS.FILE_SUFFIX) ||
      ".html";
    return state.siteRoot + docname + suffix + (anchor || "");
  }

  // --- Candidate collection -------------------------------------------------

  function collectFunctionCandidates(searchTerms) {
    var idx = Search._index;
    if (!idx || !idx.objects) return [];
    var results = [];
    var lowerTerms = searchTerms.map(function (t) {
      return t.toLowerCase();
    });

    Object.keys(idx.objects).forEach(function (moduleKey) {
      idx.objects[moduleKey].forEach(function (entry) {
        var docnameIndex = entry[0];
        var objTypeIndex = entry[1];
        var priority = entry[2];
        var name = entry[4];
        if (!name) return;
        var nameLower = name.toLowerCase();
        var score = 0;
        lowerTerms.forEach(function (term) {
          if (nameLower === term) score += Scorer.objNameMatch;
          else if (nameLower.indexOf(term) !== -1)
            score += Scorer.objPartialMatch;
        });
        if (score === 0) return;
        score += Scorer.objPrio.hasOwnProperty(priority)
          ? Scorer.objPrio[priority]
          : Scorer.objPrioDefault;

        var docname = idx.docnames[docnameIndex];
        var objTypeName =
          (idx.objnames && idx.objnames[objTypeIndex] && idx.objnames[objTypeIndex][2]) ||
          "MATLAB function";
        results.push({
          kind: "function",
          title: name,
          descr: objTypeName,
          url: docUrl(docname, "#" + moduleKey + "." + name),
          score: score,
          docname: docname,
        });
      });
    });
    return results;
  }

  function collectDocCandidates(searchTerms) {
    var idx = Search._index;
    if (!idx || !idx.titles) return [];
    var results = [];
    var lowerTerms = searchTerms.map(function (t) {
      return t.toLowerCase();
    });
    // idx.terms/idx.titleterms are keyed by Porter-stemmed words (see
    // Sphinx's own Search.performSearch, which stems each query term with
    // the same Stemmer before looking it up) -- an un-stemmed query like
    // "compilers" would otherwise never match the stored root "compil".
    var stemmer = typeof Stemmer === "function" ? new Stemmer() : null;
    var stemmedTerms = stemmer
      ? lowerTerms.map(function (t) {
          return stemmer.stemWord(t);
        })
      : lowerTerms;

    idx.docnames.forEach(function (docname, i) {
      var title = idx.titles[i];
      if (!title) return;
      var titleLower = title.toLowerCase();
      var score = 0;
      lowerTerms.forEach(function (term) {
        if (!term) return;
        if (titleLower === term) score += Scorer.title;
        else if (titleLower.indexOf(term) !== -1) score += Scorer.partialTitle;
      });
      if (score === 0) return;

      results.push({
        kind: docname.indexOf("modules/") === 0 ? "function" : "doc",
        title: title,
        descr: null,
        url: docUrl(docname),
        score: score,
        docname: docname,
      });
    });

    // Term-index matches: catch queries that hit body text but not the
    // title. idx.terms / idx.titleterms are Sphinx's inverted index -- a
    // dictionary keyed by exact Porter-stemmed word, mapping to a docname
    // index or an array of them. Sphinx's own Search.performSearch looks
    // these up by exact key (stemmed query term === stemmed dictionary
    // word), not by substring; scanning the whole dictionary for substring
    // hits (an earlier version of this function did) matches unrelated
    // words that merely contain the query as a substring (e.g. querying
    // "analysis" would also hit "reanalysis", "analyses", ...) and, worse,
    // lets a single multi-word query accumulate one score contribution per
    // incidentally-matching dictionary word instead of per query term --
    // inflating scores for pages with large, generic technical vocabularies
    // well past genuinely more relevant title/name matches.
    function scanTermTable(table, weight) {
      if (!table) return;
      stemmedTerms.forEach(function (term) {
        if (!term || !Object.prototype.hasOwnProperty.call(table, term)) return;
        var refs = table[term];
        var docIndices = Array.isArray(refs) ? refs : [refs];
        docIndices.forEach(function (docIndex) {
          if (typeof docIndex !== "number" || !idx.docnames[docIndex]) return;
          var docname = idx.docnames[docIndex];
          var existing = results.filter(function (r) {
            return r.docname === docname;
          })[0];
          if (existing) {
            existing.score += weight;
          } else {
            results.push({
              kind: docname.indexOf("modules/") === 0 ? "function" : "doc",
              title: idx.titles[docIndex],
              descr: null,
              url: docUrl(docname),
              score: weight,
              docname: docname,
            });
          }
        });
      });
    }
    scanTermTable(idx.titleterms, Scorer.title);
    scanTermTable(idx.terms, Scorer.term);

    return results;
  }

  function collectTutorialCandidates(searchTerms) {
    var lowerTerms = searchTerms.map(function (t) {
      return t.toLowerCase();
    });
    var results = [];
    state.tutorials.forEach(function (entry) {
      if (!entry || !entry.title || !entry.url) return;
      var titleLower = entry.title.toLowerCase();
      var bodyLower = (entry.body_text || "").toLowerCase();
      var score = 0;
      lowerTerms.forEach(function (term) {
        if (!term) return;
        if (titleLower === term) score += Scorer.title;
        else if (titleLower.indexOf(term) !== -1) score += Scorer.partialTitle;
        else if (bodyLower.indexOf(term) !== -1) score += Scorer.partialTerm;
      });
      if (score === 0) return;
      results.push({
        kind: "tutorial",
        title: entry.title,
        descr: null,
        url: state.siteRoot + entry.url,
        score: score,
        docname: null,
        bodyText: entry.body_text,
      });
    });
    return results;
  }

  // --- Query orchestration ---------------------------------------------------

  function runQuery(query) {
    var searchTerms =
      typeof splitQuery === "function"
        ? splitQuery(query)
        : query.split(/\s+/).filter(Boolean);
    if (!searchTerms.length) {
      renderResults([], query);
      return;
    }

    var candidates = [];
    if (hasSearch() && Search._index) {
      candidates = candidates.concat(collectFunctionCandidates(searchTerms));
      candidates = candidates.concat(collectDocCandidates(searchTerms));
    }
    candidates = candidates.concat(collectTutorialCandidates(searchTerms));

    candidates = dedupeByUrl(candidates);
    candidates.sort(function (a, b) {
      return b.score - a.score;
    });

    renderResults(candidates.slice(0, MAX_RESULTS), query, searchTerms);
  }

  function dedupeByUrl(candidates) {
    // The MATLAB domain's object table lists the same function under more
    // than one module key (e.g. both its own module and its parent
    // package), which otherwise produces visually identical duplicate rows
    // for the same target URL/anchor. Keep only the highest-scoring entry
    // per URL.
    var byUrl = {};
    candidates.forEach(function (candidate) {
      var existing = byUrl[candidate.url];
      if (!existing || candidate.score > existing.score) {
        byUrl[candidate.url] = candidate;
      }
    });
    return Object.keys(byUrl).map(function (url) {
      return byUrl[url];
    });
  }

  // --- Rendering ---------------------------------------------------------

  var KIND_LABELS = { function: "Function", doc: "Doc", tutorial: "Tutorial" };

  function renderResults(results, query, searchTerms) {
    var box = state.resultsBox;
    box.innerHTML = "";

    if (!query || query.trim().length < MIN_QUERY_LENGTH) {
      box.style.display = "none";
      return;
    }

    if (!results.length) {
      var empty = document.createElement("div");
      empty.className = "site-search-empty";
      empty.textContent = "No results found for “" + query + "”.";
      box.appendChild(empty);
      box.style.display = "block";
      return;
    }

    var list = document.createElement("ul");
    list.className = "site-search-results-list";
    results.forEach(function (result, i) {
      var item = document.createElement("li");
      item.className = "site-search-result site-search-result--" + result.kind;

      var link = document.createElement("a");
      link.href = result.url;

      var badge = document.createElement("span");
      badge.className = "site-search-badge";
      badge.textContent = KIND_LABELS[result.kind] || result.kind;
      link.appendChild(badge);

      var titleEl = document.createElement("span");
      titleEl.className = "site-search-title";
      titleEl.textContent = result.title + (result.descr ? " (" + result.descr + ")" : "");
      link.appendChild(titleEl);

      var snippetEl = document.createElement("div");
      snippetEl.className = "site-search-snippet";
      link.appendChild(snippetEl);

      item.appendChild(link);
      list.appendChild(item);

      if (result.kind === "tutorial" && result.bodyText) {
        snippetEl.textContent = summarizeText(result.bodyText, searchTerms);
      } else if (i < SUMMARY_FETCH_LIMIT && result.docname) {
        fetchSnippet(result.url, searchTerms, snippetEl);
      }
    });
    box.appendChild(list);
    box.style.display = "block";
  }

  function summarizeText(text, searchTerms) {
    if (hasSearch() && typeof Search.makeSearchSummary === "function") {
      try {
        var summaryNode = Search.makeSearchSummary(
          "<body>" + text + "</body>",
          searchTerms || []
        );
        if (summaryNode) return summaryNode.textContent || summaryNode.innerText || "";
      } catch (e) {
        /* fall through to plain-text fallback below */
      }
    }
    var plain = text.replace(/\s+/g, " ").trim();
    return plain.length > 240 ? plain.slice(0, 240) + "..." : plain;
  }

  function fetchSnippet(url, searchTerms, snippetEl) {
    fetch(url)
      .then(function (response) {
        if (!response.ok) throw new Error("page fetch failed");
        return response.text();
      })
      .then(function (html) {
        if (hasSearch() && typeof Search.makeSearchSummary === "function") {
          var summaryNode = Search.makeSearchSummary(html, searchTerms || []);
          if (summaryNode) {
            snippetEl.innerHTML = "";
            snippetEl.appendChild(summaryNode);
          }
        }
      })
      .catch(function () {
        /* leave snippet empty rather than surface a broken fetch to the visitor */
      });
  }

  // --- Wiring --------------------------------------------------------------

  function handleInput() {
    clearTimeout(state.debounceTimer);
    var query = state.input.value;
    state.debounceTimer = setTimeout(function () {
      if (!query || query.trim().length < MIN_QUERY_LENGTH) {
        renderResults([], query);
        return;
      }
      runQuery(query.trim());
    }, DEBOUNCE_MS);
  }

  function init(options) {
    state.siteRoot = options.siteRoot || "";
    state.searchIndexUrl = options.searchIndexUrl;
    state.tutorialsIndexUrl = options.tutorialsIndexUrl;
    state.input = document.getElementById(options.inputId || "simple");
    if (!state.input) return;

    state.resultsBox = document.createElement("div");
    state.resultsBox.className = "site-search-results";
    state.resultsBox.style.display = "none";
    state.input.parentNode.insertBefore(
      state.resultsBox,
      state.input.nextSibling
    );

    // Prevent the plain form submit (full navigation to search.html) from
    // firing while the visitor is interacting with the instant results.
    state.input.addEventListener("keydown", function (evt) {
      if (evt.key === "Enter") evt.preventDefault();
    });
    state.input.addEventListener("input", handleInput);
    document.addEventListener("click", function (evt) {
      if (!state.resultsBox.contains(evt.target) && evt.target !== state.input) {
        state.resultsBox.style.display = "none";
      }
    });

    if (hasSearch() && typeof Search.loadIndex === "function") {
      Search.loadIndex(state.searchIndexUrl);
    }
    onSearchIndexReady(function () {
      // Re-run the current query once the index arrives, in case the visitor
      // typed before it finished loading.
      if (state.input.value.trim().length >= MIN_QUERY_LENGTH) {
        runQuery(state.input.value.trim());
      }
    });
    loadTutorialsIndex();
  }

  return { init: init };
})();
