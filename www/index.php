<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);
$themeroot='r-forge.r-project.org/themes/rforge/';

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<!DOCTYPE html
	PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en   ">

  <head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title><?php echo $group_name; ?></title>
	<link href="http://<?php echo $themeroot; ?>styles/estilo1.css" rel="stylesheet" type="text/css" />
  <meta name="description" content="Parametric frailty models in R" />
  <meta name="keywords" content="parametric, frailty, frailty models, survival, R, package" /> 
  </head>

<body>

<!-- R-Forge Logo -->
<table border="0" width="100%" cellspacing="0" cellpadding="0">
<tr><td>
<a href="http://r-forge.r-project.org/"><img src="http://<?php echo $themeroot; ?>/imagesrf/logo.png" border="0" alt="R-Forge Logo" /> </a> </td> </tr>
</table>


<!-- project title  -->

<h2>Parametric Frailty Models in R</h2>

<p>Frailty Models [<a href="#DJ08">1</a>,<a href="#W10">2</a>] are survival models for clustered or overdispersed duration data.
  They consist in proportional hazards Cox models [<a href="#C72">3</a>] with the addition of a random effect, accounting for different levels of risk
    due to unobserved covariates.
<p>Accoridng to the focus of the interest, estimation of parameters can be done by means of either a parametric or a semiparametric model.
  In the latter case, the baseline hazard is left unspecified and the penalized partial likelihood is considered [<a href="#TGP03">4</a>].
  Estimation can be done in R by means of the
    <a href="http://stat.ethz.ch/R-manual/R-patched/library/survival/html/coxph.html"><tt>coxph</tt></a> function 
    in the <a href="http://cran.r-project.org/web/packages/survival/index.html"><tt>survival</tt></a> package.

<p>In the case of semiparametric frailty models, estimation is based on the marginal likelihood.
  Here we provide R functions for many of the most common models.</br>
  Possible basline hazards are
  <ul> <li>Weibull,</li> <li>Exponential,</li> <li>Gompertz,</li> <li>logNormal,</li> <li>loglogistic.</li> </ul>
 Possible Frailty distributions are
  <ul> <li>Gamma,</li> <li>Inverse Gaussian,</li> <li>Positive Stable.</li> </ul>
The method is analogous to that of the Stata
  <tt><a href = "http://www.stata.com/help.cgi?streg">streg</a></tt> command [<a href="#G02">5</a>],
  the difference being that <tt>streg</tt> command offers one more baseline (the generalized gamma survival distribution)
  and one less frailty distribution (the Positive Stable).


<p> The project summary page can be found
  <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><strong>here</strong></a>. </p>


<!--References-->
<h3>References</h3>
<p> [<a name="DJ08">1</a>] Duchateau, L. & Janssen, P. (2008) 
  <em><a href="http://www.springer.com/statistics/life+sciences,+medicine+%26+health/book/978-0-387-72834-6">The frailty model</a></em>.
  Springer.</p>
<p> [<a name="W10">2</a>] Wienke, A. (2010)
  <em><a href="http://dx.doi.org/10.1201/9781420073911">Frailty Models in Survival Analysis</a></em>.
  Chapman & Hall/CRC biostatistics series. Taylor and Francis.</p>
<p> [<a name="C72">3</a>] Cox, D. R. (1972)
  <a href="http://www.jstor.org/stable/2985181">Regression models and life-tables</a>. 
  <em>Journal of the Royal Statistical Society. Series B (Methodological)</em> 34, 187–220.</p>
<p> [<a name="TGP03">4</a>] Therneau, T. M., Grambsch, P. M. & Pankratz, V. S. (2003) 
  <a href="http://dx.doi.org/10.1198/1061860031365">Penalized survival models and frailty</a>.
  <em>Journal of Computational and Graphical Statistics</em> 12, 156–175.</p>
<p> [<a name="G02">5</a>] Gutierrez, R. G.  (2002)
  <a href="http://www.stata-journal.com/article.html?article=st0006">Parametric frailty and shared frailty survival models</a>. 
  <em>Stata Journal</em> 2(1), 22-44.</p>

</body>
</html>
