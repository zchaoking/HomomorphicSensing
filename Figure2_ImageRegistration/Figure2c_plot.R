library(R.matlab);
library(ggplot2);
library(latex2exp);
library(tidyverse);
library(scales);

text_size = element_text(size=20);
title_text_size = element_text(size=20+10);
point_size = 7;

types = c('fish', 'fu');
max_iter = "Inf";

for(typei in c(1,2)){
    type = types[typei];
    if (typei == 1) {
      titlename = "Fish";
    } else {
      titlename = "The Chinese Character";
    }

    saving_path = sprintf("./Figure2c_%s.eps", type);

    fn = sprintf('./results/FishFu_MissingPointswithNoise_%s_iter=%s.mat', type, max_iter);
    res = readMat(fn);

    l = length(res$missing.ratios);
    missing_ratios = res$missing.ratios[1,1:l];

    start = 1; end=l;
    BnB_mean = res$es.BnB.mean[start:end, 1];
    BnB_std = res$es.BnB.std[start:end, 1];

    APM_mean = res$es.APM.mean[start:end, 1];
    APM_std = res$es.APM.std[start:end, 1];

    CPD_mean = res$es.CPD.mean[1:l, 1];
    CPD_std = res$es.CPD.std[1:l, 1];
    GMMREG_mean = res$es.GMMREG.mean[1:l, 1];
    GMMREG_std = res$es.GMMREG.std[1:l, 1];

    means = c(BnB_mean,
              APM_mean,
              CPD_mean, GMMREG_mean);
    stds = c(BnB_std,
             APM_std,
             CPD_std, GMMREG_std);

    missing_ratios = rep(c(missing_ratios), 4);
    groups = factor(c(rep("Algorithm-C", l),
                      rep("APM", l),
                      rep("CPD", l),
                      rep("GMMREG", l)),
                      levels=c("GMMREG", "CPD",
                               "APM",
                               "Algorithm-C"));

    dat = data.frame(missing_ratios, means, stds, groups);

    shape_values = c("Algorithm-C"=21,
                     "APM"=22,
                     "CPD"=5,
                     "GMMREG"=2);
    fill_values = c("Algorithm-C"="red",
                    "APM"="black",
                    "CPD"="lightslateblue",
                    "GMMREG"="lightblue");

    p = ggplot(data=dat, mapping=aes(x=missing_ratios, y=means,
                         #colour=groups,
                         fill=groups,
                         shape=groups
                         )) +
      geom_line(position=position_dodge(0.02)) +
      geom_point(position=position_dodge(0.02), size=point_size) +
      # geom_errorbar(position=position_dodge(0.005), aes(ymin=means-stds, ymax =means+stds), width = 0.02) +
      scale_shape_manual(values=shape_values)+
      scale_fill_manual(values = fill_values)+

      # scale_y_continuous(breaks=seq(0,0.4,0.1),
      #                    labels=c("0","0.1","0.2","0.3","0.4")) +
      scale_y_log10(breaks=10^(-2:0),
                    # labels=seq(10^(-2), 10^(-1), 1)
                    labels=trans_format("log10", math_format(10^.x))) +


      scale_x_continuous(breaks=seq(0, 0.5, 0.1),
                         labels=c("0%","10%","20%","30%","40%","50%")) +

      labs(x="Outlier Ratio",y="Registration Error", title=TeX(titlename));

      if (typei == 1){
      p=p+
        theme(axis.text=element_text(face="plain", size=32, color='gray10'),
            legend.text=element_text(face="plain",size=32, family="mono"),
            title=element_text(face="plain",size=32, color='gray10'),
            plot.title=element_blank(),
            legend.background=element_rect(colour='gray90', fill='gray90'),
            legend.key=element_rect(color='gray90'),
            legend.title=element_blank(), legend.position=c(0.5,0.5), # legend.direction="horizontal",
            legend.spacing.x=unit(0.2,"lines"), legend.key.size = unit(2, 'lines')
            )
      ggsave(saving_path, device="pdf",
           width=8,height=7)
      }
      else {
        p=p+
            theme(axis.text=element_text(face="plain", size=32, color='gray10'),
            legend.text=element_text(face="plain",size=32, family="mono"),
            title=element_text(face="plain",size=32, color='gray10'),
            plot.title=element_blank(),
            legend.background=element_rect(colour='gray90', fill='gray90'),
            legend.key=element_rect(color='gray90'),
            legend.title=element_blank(), legend.position=c(0.5,0.5),
            legend.spacing.x=unit(0.2,"lines"), legend.key.size = unit(2, 'lines')
            )
        ggsave(saving_path, device="pdf",
            width=8,height=7)
      }
}
