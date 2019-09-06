FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

RUN R -e 'devtools::install_github("rcannood/SCORPIUS@dynwrap", dependencies = TRUE)'

RUN mkdir /code; \
  PACKPATH=`Rscript -e 'cat(system.file("dynwrap", package = "SCORPIUS"), "\n", sep = "")'`; \
  cp $PACKPATH/run.R $PACKPATH/example.sh $PACKPATH/definition.yml /code

ENTRYPOINT ["/code/run.R"]
