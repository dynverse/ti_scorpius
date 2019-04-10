FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

COPY definition.yml run.R example.sh package/ /code/

RUN R -e 'devtools::install("/code/", dependencies = TRUE, quick = TRUE)'

ENTRYPOINT ["/code/run.R"]
