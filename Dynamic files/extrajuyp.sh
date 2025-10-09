set -e

apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  build-essential cmake pkg-config gcc g++ gfortran make autoconf automake libtool \
  curl wget git git-lfs ca-certificates unzip zip tar xz-utils bzip2 p7zip-full \
  python3-dev python3-tk \
  nodejs npm \
  rustc cargo golang \
  default-jdk openjdk-17-jre-headless maven gradle \
  libssl-dev zlib1g-dev libbz2-dev liblzma-dev libffi-dev libreadline-dev \
  libxml2-dev libxslt1-dev libpq-dev libsqlite3-dev libmysqlclient-dev \
  libsasl2-dev libldap2-dev libkrb5-dev \
  libhdf5-dev libnetcdf-dev \
  libopenblas-dev liblapack-dev \
  libgmp-dev libmpfr-dev libmpc-dev \
  libboost-all-dev \
  libsnappy-dev libzstd-dev liblz4-dev \
  libmagic1 \
  graphviz \
  tesseract-ocr tesseract-ocr-all \
  poppler-utils qpdf ghostscript \
  texlive-full pandoc \
  libjpeg-turbo-progs libpng-dev libtiff-dev libwebp-dev libopenjp2-7-dev \
  libfreetype6-dev libharfbuzz-dev libfribidi-dev libcairo2 libcairo2-dev libpango-1.0-0 libpango1.0-dev \
  libglib2.0-0 libglib2.0-dev \
  libglvnd0 libgl1-mesa-glx libglu1-mesa libgles2-mesa libegl1 \
  libx11-6 libxext6 libsm6 libxrender1 libxi6 libxrandr2 libxxf86vm1 libxkbcommon0 libxkbcommon-x11-0 \
  freeglut3-dev mesa-utils xvfb \
  libasound2 libasound2-dev libpulse0 libportaudio2 portaudio19-dev \
  ffmpeg gstreamer1.0-tools gstreamer1.0-libav \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad \
  libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
  opencl-headers ocl-icd-libopencl1 \
  r-base r-base-dev \
  julia \
  gdal-bin proj-bin libgdal-dev libproj-dev libgeos-dev libspatialindex-dev \
  postgresql-client mysql-client sqlite3 redis-tools rabbitmq-server \
  librdkafka-dev \
  libsodium-dev \
  locales \
  && rm -rf /var/lib/apt/lists/*

python -m pip install --upgrade pip wheel setuptools

pip install --no-cache-dir \
  numpy scipy pandas polars pyarrow fastparquet dask[complete] ray[default] vaex \
  scikit-learn scikit-image statsmodels numba numexpr bottleneck \
  matplotlib seaborn plotly bokeh altair holoviews hvplot panel datashader \
  xarray netCDF4 h5py tables \
  xgboost lightgbm catboost \
  onnx onnxruntime onnxconverter-common \
  torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
  tensorflow-cpu jax jaxlib \
  optuna scikit-optimize hyperopt bayesian-optimization nevergrad \
  cvxpy pulp ortools cvxopt \
  prophet pmdarima orbit-ml neuralprophet kats \
  ruptures statsforecast darts \
  mlflow hydra-core wandb \
  transformers datasets accelerate peft diffusers \
  sentence-transformers sentencepiece tiktoken \
  spacy spacy-lookups-data stanza flair \
  nltk gensim fasttext \
  openai anthropic google-generativeai together ai21 \
  langchain langchain-core langchain-community langchain-text-splitters \
  llama-index llama-index-llms-openai llama-index-embeddings-huggingface \
  chromadb qdrant-client weaviate-client milvus pymilvus faiss-cpu annoy nmslib hnswlib \
  textstat textacy keybert yake rake-nltk lexrank sumy \
  opencv-python opencv-contrib-python imageio imageio-ffmpeg pillow pillow-avif-plugin \
  tifffile pyheif pyvips scikit-video \
  pyopengl PyOpenGL_accelerate moderngl moderngl-window vispy \
  pythreejs ipycanvas ipyevents ipyvtklink vtk mayavi \
  shapely pyrr trimesh pyrender open3d meshio pyassimp laspy pyntcloud \
  rembg \
  sounddevice soundfile pyaudio librosa resampy audioread noisereduce \
  pydub aubio musdb sphinx-measurement \
  faster-whisper openai-whisper speechrecognition vosk \
  tts torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cpu \
  pygame pyglet arcade ursina panda3d panda3d-gltf panda3d-simplepbr kivy \
  Box2D-py pymunk pybullet mujoco \
  gymnasium gymnasium[atari,accept-rom-license] gymnasium[classic-control,mujoco] \
  pettingzoo supersuit shimmy \
  sb3-contrib stable-baselines3 tianshou ray[rllib] \
  simpy gymnax dm-control brax \
  manim manimpango \
  pyvista vedo napari napari[all] \
  streamlit dash gradio fastapi uvicorn[standard] starlette \
  flask waitress gunicorn sanic tornado \
  nicegui textual rich textual-dev \
  jupyter jupyterlab ipykernel ipywidgets jupytext nbconvert papermill \
  jupyterlab-git jupyter-resource-usage jupyterlab_execute_time jupyterlab_code_formatter nbclient nbformat \
  nbqa black isort ruff pylint mypy pyflakes autoflake yapf \
  playwright selenium webdriver-manager \
  aiohttp httpx requests[security] websockets socketio \
  uvloop anyio trio \
  tenacity tqdm loguru structlog rich-click typer click fire \
  openpyxl xlsxwriter xlrd pyxlsb pandasql \
  pypdf pdfminer.six pymupdf pikepdf pdfplumber camelot-py[cv] tabula-py \
  pytesseract \
  python-docx docx2txt mammoth python-pptx pypandoc reportlab weasyprint xhtml2pdf \
  markdown markdown-it-py mistune mdformat beautifulsoup4 lxml html5lib selectolax trafilatura newspaper3k \
  unstructured unstructured[pdf,docx,pptx,md,html,image] \
  scrapy parsel itemadapter itemloaders splash \
  sqlalchemy alembic sqlmodel \
  psycopg2-binary pymysql oracledb \
  sqlite-utils duckdb duckdb-engine \
  pymongo redis cassandra-driver \
  elasticsearch opensearch-py \
  clickhouse-driver clickhouse-connect \
  trino pyhive[hive] thrift sasl thrift-sasl \
  neo4j py2neo networkx python-igraph graph-tool==2.59.post1 || true \
  boto3 botocore s3fs minio \
  google-cloud-storage google-cloud-bigquery google-cloud-aiplatform google-cloud-pubsub \
  azure-storage-blob azure-identity azure-kusto-data \
  fastavro confluent-kafka kafka-python \
  prefect dagster dlt \
  apache-airflow==2.10.2 || true \
  pydantic pydantic-settings dataclasses-json marshmallow marshmallow-dataclass \
  orjson ujson msgpack rapidjson simplejson \
  dill joblib cloudpickle \
  cryptography pyjwt pynacl nacl \
  pyarrow-hotfix \
  pyproj rasterio fiona geopandas rtree contextily folium keplergl leafmap osmnx movingpandas \
  geovoronoi geoplot geopy mercantile mapclassify \
  dgl dglgo --find-links https://data.dgl.ai/wheels/repo.html || true

python - <<'PY'
import spacy, sys
for m in ["en_core_web_sm","en_core_web_md","de_core_news_sm","nl_core_news_sm"]:
    try:
        spacy.cli.download(m)
    except SystemExit:
        pass
print("OK")
PY

python -m playwright install --with-deps || true
npm -g install yarn pnpm @mermaid-js/mermaid-cli @openapitools/openapi-generator || true

R -q -e "install.packages(c('IRkernel','tidyverse','data.table','arrow','DBI','RPostgres','RSQLite','RMariaDB','duckdb','reticulate','sf','terra','sp','rgdal','rgeos','tmap','leaflet','plotly','data.table','ggplot2','shiny','plumber','future','furrr','targets','tarchetypes','randomForest','xgboost','lightgbm','ranger','glmnet','caret','forecast','prophet','tseries','urca','Rcpp','RcppArmadillo'), repos='https://cloud.r-project.org')" || true
R -q -e "IRkernel::installspec(user = FALSE, name = 'ir', displayname = 'R (IRkernel)')" || true

julia -e 'using Pkg; Pkg.add(["IJulia","DataFrames","CSV","Parsers","JSON3","Arrow","Plots","StatsBase","Distributions","Flux","MLJ","GLM","HTTP","Genie","Images","ImageIO","PyPlot","PlotlyJS","Makie","GeoStats","ArchGDAL","DecisionTree","Turing","Optimization","JuMP","Ipopt"]); using IJulia' || true

python - <<'PY'
mods = [
 "numpy","scipy","pandas","polars","pyarrow","dask","sklearn","statsmodels","numba",
 "matplotlib","seaborn","plotly","bokeh","altair","panel","hvplot","holoviews",
 "torch","onnxruntime","tensorflow","jax","transformers","datasets","sentence_transformers","tiktoken",
 "spacy","stanza","flair","nltk","opencv","PIL","imageio","vtk","mayavi","trimesh","pyrender","open3d",
 "sounddevice","soundfile","pyaudio","librosa","pydub","aubio","whisper","faster_whisper",
 "pygame","pybullet","mujoco","gymnasium","stable_baselines3","pettingzoo",
 "streamlit","dash","gradio","fastapi","uvicorn","flask",
 "jupyter","ipywidgets","jupytext","nbconvert","jupyterlab",
 "geopandas","shapely","rasterio","fiona","pyproj","rtree","folium","osmnx",
 "pypdf","pdfminer","fitz","pytesseract","python_docx","bs4","lxml","scrapy",
 "sqlalchemy","psycopg2","pymysql","duckdb","pymongo","redis","cassandra","elasticsearch",
 "faiss","chromadb","qdrant_client","weaviate",
 "boto3","google.cloud.storage","google.cloud.bigquery","azure.storage.blob",
 "langchain","llama_index","optuna","prophet","pmdarima","cvxpy","ortools"
]
bad=[]
for m in mods:
    try:
        __import__(m)
    except Exception as e:
        bad.append((m,str(e)))
print("FAILED:", bad if bad else "NONE")
PY
