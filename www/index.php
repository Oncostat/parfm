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

<p>Frailty Models [1,2] are survival models for clustered or overdispersed duration data.
  They consist in proportional hazards Cox models [3] with the addition of a random effect, accounting for different levels of risk
    due to unobserved covariates.
<p>Accoridng to the focus of the interest, estimation of parameters can be done by means of either a parametric or a semiparametric model.
  In the latter case, the baseline hazard is left unspecified and the penalized partial likelihood is considered [4].
  Estimation can be done in R by means of the
    <a href="http://stat.ethz.ch/R-manual/R-patched/library/survival/html/coxph.html"><tt>coxph</tt></a> function 
    in the <a href="http://cran.r-project.org/web/packages/survival/index.html"><tt>survival</tt></a> package.

<p>Here we provide code for estimating frailty models, based on the marginal likelihood, for many of the most common models.
  Possible basline hazards are
  <ul> <li>Weibull,</li> <li>Exponential,</li> <li>Gompertz,</li> <li>logNormal,</li> <li>loglogistic.</li> </ul>
 Possible Frailty distributions are
  <ul> <li>Gamma,</li> <li>Inverse Gaussian,</li> <li>Positive Stable.</li> </ul>
The method is analogous to that of the Stata
  <tt><a href = "http://www.stata-journal.com/article.html?article=st0006">streg</a></tt> command [5],
  the difference being that <tt>streg</tt> offers one more baseline (the generalized gamma survival distribution)
  and one less frailty distribution (the Positive Stable).


<h3>References</h3>
<p> [1] Duchateau, L. & Janssen, P. (2008) <em>The frailty model</em>. Springer.</p>
<p> [2] Wienke, A. (2010) <em>Frailty Models in Survival Analysis</em>. Chapman & Hall/CRC biostatistics series. Taylor and Francis.</p>
<p> [3] Cox, D. R. (1972) Regression models and life-tables. 
  <em>Journal of the Royal Statistical Society. Series B (Methodological)</em> 34, 187–220.</p>
<p> [4] Therneau, T. M., Grambsch, P. M. & Pankratz, V. S. (2003) Penalized survival models and frailty.
  <em>Journal of Computational and Graphical Statistics</em> 12, 156–175.</p>
<p> [5] Gutierrez, R. G.  (2002) Parametric frailty and shared frailty survival models. 
  <em>Stata Journal</em> 2, 22-44.</p>

<p>
<p> The <tt>project summary page</tt> you can find <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><tt>here</tt></a>. </p>

</body>
</html>
