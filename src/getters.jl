# We use getters so the model never accesses struct fields directly, 
# except in methods for specific leaf types where declaring all the gettier 
# methods would be overkill.
#
# A benefit of this is parameters can be easily moved between shared and specific 
# parameter structs.

# So we don't have to depend on all of Lazy.jl
macro forward(ex, fs)
  @capture(ex, T_.field_) || error("Syntax: @forward T.x f, g, h")
  T = esc(T)
  fs = isexpr(fs, :tuple) ? map(esc, fs.args) : [esc(fs)]
  :($([:($f(x::$T, args...) = (Base.@_inline_meta; $f(x.$field, args...)))
       for f in fs]...);
    nothing)
end



@inline dead(o::AbstractOrganism) = o.dead[]
@inline set_dead!(o::AbstractOrganism, val) = o.dead[] = val

@inline environment(o::AbstractOrganism) = o.environment
@inline vars(o::AbstractOrgan) = o.vars

@inline flux(o::AbstractOrgan) = o.J
@inline flux1(o::AbstractOrgan) = o.J1

@inline tstep(v) = v.t[1]
@inline set_tstep!(v, val) = v.t[1] = val  

@inline assimilation_vars(v) = v.assimilation_vars

@inline shape(v) = v.shape[tstep(v)]
@inline set_shape!(v, val) = v.shape[tstep(v)] = val

@inline rate(v) = v.rate[tstep(v)]
@inline set_rate!(v, val) = v.rate[tstep(v)] = val

@inline temp(v) = v.temp[tstep(v)]
@inline set_temp!(v, val) = v.temp[tstep(v)] = val

@inline θE(v) = v.θE[tstep(v)]
@inline set_θE!(v, val) = v.θE[tstep(v)] = val

@inline tempcorrection(v) = v.tempcorrection[tstep(v)]
@inline set_tempcorrection!(v, val) = v.tempcorrection[tstep(v)] = val

@inline depth(v) = height(v)
@inline height(v) = v.height[tstep(v)]
@inline set_height!(v, val) = v.height[tstep(v)] = val

@inline set_var!(vars, fname, val) = setfield!(getfield(vars, fname), tstep(vars), fname)

rate_formula(p) = p.rate_formula
assimilation_pars(p) = p.assimilation_pars
shape_pars(p) = p.shape_pars
allometry_pars(p) = p.allometry_pars
maturity_pars(p) = p.maturity_pars
trans_pars(p) = p.trans_pars
production_pars(p) = p.production_pars
rejection_pars(p) = p.rejection_pars
germination_pars(p) = p.germination_pars
turnover_pars(p) = p.turnover_pars
feedback_pars(p) = p.feedback_pars
tempcorr_pars(p) = p.tempcorr_pars
core_pars(p) = p.core_pars
su_pars(p) = p.su_pars
catabolism_pars(p) = p.catabolism_pars
maintenance_pars(p) = p.maintenance_pars

@forward AbstractOrgan.vars θE, temp, set_temp!, tempcorrection, set_tempcorrection!, 
         set_var!, height, set_height!, rate, set_rate!, shape, set_shape!, tstep, set_tstep!, assimilation_vars 

@forward AbstractOrgan.params rate_formula, assimilation_pars, shape_pars, allometry_pars, maturity_pars,
                              trans_pars, production_pars, rejection_pars, germination_pars, turnover_pars

@forward AbstractOrgan.shared maintenance_pars, feedback_pars, su_pars, tempcorr_pars, catabolism_pars, core_pars

y_V_E(o::AbstractOrgan) = core_pars(o).y_V_E
y_E_EC(o::AbstractOrgan) = core_pars(o).y_E_EC
y_E_EN(o::AbstractOrgan) = core_pars(o).y_E_EN
n_N_P(o::AbstractOrgan) = production_pars(o).n_N_P
n_N_V(o::AbstractOrgan) = core_pars(o).n_N_V
n_N_E(o::AbstractOrgan) = core_pars(o).n_N_E
n_N_EC(o::AbstractOrgan) = core_pars(o).n_N_EC
n_N_EN(o::AbstractOrgan) = core_pars(o).n_N_EN
w_V(o::AbstractOrgan) = core_pars(o).w_V
w_C(o::AbstractOrgan) = core_pars(o).w_C 
w_N(o::AbstractOrgan) = core_pars(o).w_N
w_E(o::AbstractOrgan) = core_pars(o).w_E

@inline j_E_mai(o::AbstractOrgan) = maintenance_pars(o).j_E_mai

@inline κtra(o::AbstractOrgan) = κtra(trans_pars(o))
@inline κtra(trans_pars::AbstractTranslocation) = trans_pars.κtra
@inline κtra(o::Nothing) = 0.0

@inline κmat(o::AbstractOrgan) = κmat(maturity_pars(o))
@inline κmat(maturity_pars::Maturity) = maturity_pars.κmat
@inline κmat(::Nothing) = 0.0

@inline k_EC(p::AbstractCatabolism) = p.k_E
@inline k_EN(p::AbstractCatabolism) = p.k_E
@inline k_E(p::AbstractCatabolism) = p.k_E

@inline κsoma(o::AbstractOrgan) = (oneunit(κtra(o) - κtra(o) - κmat(o)))
@inline mass(o, u) = u.V * w_V(o)
