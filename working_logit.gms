*Read excel file
$call gdxxrw.exe test.xlsx par=data1 rng=sheet2!A1:E1672 par=data2 rng=sheet2!F1:J1672 par=choice rng=sheet2!K1:L1672

set     n(*)                Index of data in the model,
        t(*)                Index of observations;

parameter  data1(t,*)        Source data,
           data2(t,*)        Source data,
           choice(t,*);

*Load data from GDX
$gdxin test.gdx
*$gdxin in.gdx
$load t < data1.dim1
$load n < data1.dim2
$loaddc data1, data2, choice
$gdxin

parameter       y1(t)         Choice 1 is selected,
                y2(t)         Choice 2 is selected;

*        Dependent variable, active credit accounts only
y1(t) = 0;
y2(t) = 0;

*Positive if second alternative is chosen
y1(t) = 1$(choice(t,"CHOICE")=1);
y2(t) = 1$(choice(t,"CHOICE")=2);

*display y1, y2;

*        Loglikelihood maximization
variable        BETA(n)           Coefficients to be estimated,
                LOGLIK            Loglikelihood;

Binary Variable r1(t), r2(t);

equations        obj               Objective for a unrestricted model,
                 route(t)          Route choice for an observation t;

route(t)..   r1(t)+r2(t) =e= 1;

obj..       LOGLIK =e= sum(t, y1(t)*log(exp(sum(n, data1(t,n)*BETA(n)))/(exp(sum(n, data1(t,n)*BETA(n))) +
                       exp(sum(n, data2(t,n)*BETA(n))))) + y2(t)*log(exp(sum(n, data2(t,n)*BETA(n)))/
                       (exp(sum(n, data1(t,n)*BETA(n))) + exp(sum(n, data2(t,n)*BETA(n))))));

model logit  /obj/;

solve logit maximizing LOGLIK using nlp;


