import sys,re,ast
src,out=sys.argv[1],sys.argv[2]
lines=open(src).read().split('\n')
exe=ast.literal_eval(open(out).read().split('\n')[1].replace(' ',','))
# executable = non-blank, non-comment, not just end/else/otherwise/case/function-continuation
skip=re.compile(r'^\s*(%.*|end|else|otherwise|case\b.*|)\s*$')
run=[i+1 for i,l in enumerate(lines) if not skip.match(l)]
miss=[n for n in run if n not in set(exe)]
print(open(out).read().split('\n')[0]); print('runnable',len(run),'executed',len(run)-len(miss)); print('not executed:',miss)
