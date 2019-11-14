using JuMP, Clp, Printf

d = [40 60 75 25 36]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:5] <= 40)       # boats produced with regular labor
@variable(m, y[1:5] >= 0)             # boats produced with overtime labor
@variable(m, h[1:6] >= 0)             # boats held in inventory

@constraint(m, h[1] == 10)
@constraint(m, h[2] == 15)
@constraint(m, flow[i in 2:5], h[i]+x[i]+y[i]==d[i]+h[i+1])     # conservation of boats
@constraint(m, h[6] >= 10)
@objective(m, Min, 400*sum(x[2:5]) + 450*sum(y[2:5]) + 20*sum(h[2:end]))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]), value(x[5]),)
@printf("Boats to build extra labor: %d %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]), value(y[5]),)
@printf("Inventories: %d %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]), value(h[6]))

@printf("Objective cost: %f\n", objective_value(m))
