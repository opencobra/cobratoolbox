/*
 * Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
 * Free for non-commerical use, for more information: see LICENSE.txt
 * http://cmb.helmholtz-muenchen.de/odefy
 */

package odefy.ui.hillparameters;

public class Table {

	private Integer[] inspecies;
	private Integer[][] truth;
	
	public Integer[] getInspecies() {
		return inspecies;
	}

	public void setInspecies(Integer[] inspecies) {
		this.inspecies = inspecies;
	}

	public Integer[][] getTruth() {
		return truth;
	}

	public void setTruth(Integer[][] truth) {
		this.truth = truth;
	}

	public Table(Integer[] inspecies, Integer[][] truth) {
		this.inspecies = inspecies;
		this.truth = truth;
	}
	
	public Table(Integer[] inspecies) {
		this(inspecies, null);
	}
	
}
