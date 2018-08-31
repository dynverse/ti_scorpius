FROM dynverse/dynwrap:r

LABEL version 0.1.1

RUN R -e 'devtools::install_cran("SCORPIUS")'

ADD . /code

ENTRYPOINT Rscript /code/run.R
