FROM opensuse/leap:15.2

LABEL maintainer="Hunsaker Consulting <hunsakerconsulting@gmail.com>"
ENV RUNNING_IN_DOCKER true

# Fetch build dependencies
RUN zypper addrepo https://download.opensuse.org/repositories/openSUSE:Leap:15.2:Update/standard/openSUSE:Leap:15.2:Update.repo
RUN zypper refresh && zypper -n install -t pattern \
    devel_C_C++ \
    devel_basis \
    devel_java \
    devel_python3 \
    devel_qt5 \
    devel_rpm_build console
RUN zypper -n install \
    glibc-devel \
    texlive \
    autoconf \
    automake \
    libtool \
    pkg-config \
    doxygen \
    ant \
    libxslt-devel \
    libxslt-tools\
    java-11-openjdk-devel \
    wget \
    freetype-devel \
    libwmf-devel \
    liblcms2-devel \
    libxml2-devel \
    libyaml-devel \
    libpng16-devel \
    libtiff-devel \
    libtiff5 \
    libopenjp2-7 \
    libopenjpeg1 \
    libgif7 \
    zlib-devel \
    zlibrary-devel \
    libicu-devel \
    libpango-1_0-0 \
    libpangomm-2_44-1 \
    libcairo2 \
    mozilla-nss-devel \
    pandoc \
    tree \
    zsh \
    cairo-devel \
    cairo-tools \
    libcairo2 \
    openjpeg2-devel \
    tmux \
    git \
    perl \
    libQt5Core5 \
    libQt5Gui5 \
    libQt5Xml5 \
    libQt5Widgets5 \
    libQt5Test5 \
    libQt5Script5 \
    libqt5-qtpaths \
    libqt5-qttools \
    libQt5Location5 \
    apache-pdfbox \
    libboost_system1_66_0-32bit \
    poppler-tools \
    libxml2-tools \
    cmake-full \
    R-base \
    unpaper \
    ruby \
    nodejs14 \
    npm14 \
    cmake 
RUN ldconfig -v

# Download GitHub Repos via HTTPS
WORKDIR /home
RUN git clone https://github.com/liblouis/liblouis.git
RUN git clone https://github.com/liblouis/liblouisutdml.git
RUN git clone git://git.ghostscript.com/ghostpdl.git
RUN git clone https://github.com/ImageMagick/ImageMagick.git
RUN git clone https://github.com/DanBloomberg/leptonica.git
RUN git clone https://github.com/tesseract-ocr/tesseract.git
RUN git clone https://github.com/rbeezer/mathbook.git
RUN git clone https://github.com/zorkow/speech-rule-engine.git

# Install LibLouis
WORKDIR /home/liblouis
RUN sh ./autogen.sh
RUN ./configure --enable-ucs4 &&  make && make install 
RUN ldconfig -v

# Install Python Bindings for LibLouis
WORKDIR /home/liblouis/python
RUN python3 setup.py install
RUN ldconfig -v

# Install LibLouisUTDML
WORKDIR /home/liblouisutdml
RUN sh ./autogen.sh
RUN ./configure && make && make install  
RUN ldconfig -v

# Install java bindings for LibLouisUTDML
WORKDIR /home/liblouisutdml/java
RUN ant
RUN ldconfig -v

# Install Ghostscript
WORKDIR /home/ghostpdl
RUN sh ./autogen.sh
RUN ./configure && make && make install 
RUN ldconfig -v

# Install Image-Magick 7
WORKDIR /home/ImageMagick
RUN ./configure && make && make install
RUN /sbin/ldconfig -v

# Install Leptonica
WORKDIR /home/leptonica
RUN sh ./autogen.sh
RUN ./configure && make && make install
RUN /sbin/ldconfig -v

# Install Tesseract-OCR
WORKDIR /home/tesseract
RUN sh ./autogen.sh
RUN ./configure && make && make install 
RUN /sbin/ldconfig -v

# Install Language Files for Tesseract-OCR
WORKDIR /usr/local/share/tessdata
RUN wget https://github.com/tesseract-ocr/tessdata_best/blob/master/eng.traineddata\?raw=true -O eng.traineddata
RUN wget https://github.com/tesseract-ocr/tessdata_best/blob/master/fra.traineddata\?raw=true -O fra.traineddata
RUN wget https://github.com/tesseract-ocr/tessdata_best/blob/master/deu.traineddata\?raw=true -O deu.traineddata

RUN zypper -n install python3-pip 

# Set up Python for Image Extraction
WORKDIR /usr/src/app
RUN pip install --upgrade pip && \
    pip install \
    numpy \
    opencv-python \
    python-math \
    argparse \
    argparse-utils \
    matplotlib \
    pytesseract \
    pylouis \
    cython \
    ipython \
    jupyter \
    pandas \
    Scipy \
    glob2 \
    scipy \
    scikit-learn \
    pandas \
    Pillow 

# Set up MathJax and SRE
RUN npm install -g npm@latest
RUN npm install mathjax-full 
RUN npm install google-closure-compiler 
RUN npm install google-closure-library 
RUN npm install xmldom-sre 
RUN npm install wicked-good-xpath 
RUN npm install  commander 
RUN npm install xml-mapping 
RUN npm install mathoid 
RUN npm install MathJax-node 
RUN npm install mathjax-node-sre 
RUN npm install speech-rule-engine

WORKDIR /home
RUN rm -rf /home/liblouis
RUN rm -rf /home/liblouisutdml
RUN rm -rf /home/ghostpdl
RUN rm -rf /home/ImageMagick
RUN rm -rf /home/leptonica
RUN rm -rf /home/tesseract

WORKDIR /home
RUN /bin/zsh
ENTRYPOINT [ "/bin/zsh" ]
