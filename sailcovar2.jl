using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, c_p[1:4] >= 0)           # Increase in production 
@variable(m, c_n[1:4] >= 0)           # Decrease in production

@constraint(m, h[1] == 10)
# @constraint(m, h[1]+d[1]==10+x[1]+y[1])     
@constraint(m, [i in 1:4], h[i]+x[i]+y[i]==d[i]+h[i+1])     

@constraint(m, x[1]+y[1]-50==c_p[1]-c_n[1])   
@constraint(m, [i in 2:4], x[i]+y[i] - (x[i-1] + y[i-1])==c_p[i]-c_n[i])   

@constraint(m, h[5] >= 10)  
@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(c_p) + 500*sum(c_n))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Increase in production: %d %d %d %d \n ", value(c_p[1]), value(c_p[2]), value(c_p[3]), value(c_p[4]))
@printf("Decrease in production: %d %d %d %d \n ", value(c_n[1]), value(c_n[2]), value(c_n[3]), value(c_n[4]))
@printf("Objective cost: %f\n", objective_value(m))
