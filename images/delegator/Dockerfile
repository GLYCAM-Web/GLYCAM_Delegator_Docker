# Build a new Delegator image so the python version is free to change
ARG PYTHON_IMAGE=python:3.9.17-bullseye

FROM ${PYTHON_IMAGE}

#Get the image build procs and then switch it to an enviroment var so it can be
#actually used in our script
ARG GRPC_IMAGE_BUILD_PROCS
ENV GRPC_IMAGE_BUILD_PROCS=${GRPC_IMAGE_BUILD_PROCS}

# Copy requirements.txt to root directory to install the listed Python packages in requirements.txt.
COPY requirements.txt /

# Update the Docker Image OS, install any Python Packages from requirements.txt, and set the timezone
# in the Docker Image.
ARG TIMEZONE="America/New_York"
RUN apt-get update \
	&& apt-get upgrade --yes \
	&& apt-get autoremove --yes; \
	pip install \
	   -r requirements.txt \
	   --upgrade; \
	rm -rf /var/lib/apt/lists/*; \
	ln -s -f \
		/usr/share/zoneinfo/${TIMEZONE} \
		/etc/localtime \
	&& dpkg-reconfigure -f \
		noninteractive tzdata;

#get archive sig, p sure fing print is: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
RUN echo "deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-15 main" >> /etc/apt/sources.list \
        && wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
        && apt-get update \
        && apt-get install --yes --no-install-recommends --no-install-suggests \
		cmake \
		libboost-all-dev \
		graphviz \
		graphviz-dev \
		libeigen3-dev \
		swig4.0 \
	&& rm -rf /var/lib/apt/lists/*


# Creating a USER and GROUP to be used.  Prefer to fail rather than give wrong IDs.
ARG USER_ID
ARG GROUP_ID
# The name and group are only used internally and usually will not matter
ARG IMG_USER_NAME=glycam
ARG IMG_GROUP_NAME=glycam

RUN groupadd \
		--gid $GROUP_ID -o \
		${IMG_GROUP_NAME} ;

RUN useradd \
		--home-dir /home/${IMG_USER_NAME} -o \
		--shell /bin/bash \
		--create-home \
		--uid $USER_ID \
		--gid $GROUP_ID \
		${IMG_USER_NAME} ;

RUN mkdir /programs && chown -R  ${IMG_USER_NAME}:${IMG_GROUP_NAME} /programs

USER ${IMG_USER_NAME}

ENV GEMSHOME=/programs/gems \
	PYTHON_HOME=/usr/local/include/python3.9 \
	PYTHONPATH=/programs/gems \
	LD_LIBRARY_PATH=/programs/gems/gmml2/lib:/programs/gems/gmml/lib \
	GEMSMAKEPROCS=4 \
	PYTHONUNBUFFERED=1 \
        GEMS_FORCE_SERIAL_EXECUTION="True"
