FROM dynverse/dynwrap:r

RUN R -e 'devtools::install_cran("SCORPIUS")'

LABEL version 0.1.4

ADD . /code

ENTRYPOINT Rscript /code/run.R
