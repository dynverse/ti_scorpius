FROM dynverse/dynwrap_latest:v0.1.0

ARG GITHUB_PAT

RUN R -e 'remotes::install_github("rcannood/SCORPIUS@devel")'

RUN mkdir /code; \
  PACKPATH=`Rscript -e 'cat(system.file("dynwrap", package = "SCORPIUS"), "\n", sep = "")'`; \
  cp $PACKPATH/run.R $PACKPATH/example.sh $PACKPATH/definition.yml /code

ENTRYPOINT ["/code/run.R"]
