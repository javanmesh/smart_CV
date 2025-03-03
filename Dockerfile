FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libpoppler-dev \
    libpoppler-cpp-dev \
    libpoppler-glib-dev \
    libpoppler-private-dev \
    poppler-utils \
    libfreetype6-dev \
    libjpeg-dev \
    libpng-dev \
    libcairo2-dev \
    libglib2.0-dev \
    libboost-all-dev \
    fontforge \
    libfontforge-dev \
    libpango1.0-dev \
    poppler-data \
    git \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for Poppler headers
RUN ln -s /usr/include/poppler/goo /usr/include/goo

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

RUN git clone --depth 1 https://github.com/coolwanglu/pdf2htmlEX.git

# Patch CMakeLists.txt to use system Poppler
RUN sed -i '/set(CAIROOUTPUTDEV_PATH 3rdparty\/poppler\/git)/,+9d' pdf2htmlEX/CMakeLists.txt && \
    sed -i 's/include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})/include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} \/usr\/include\/poppler)/' pdf2htmlEX/CMakeLists.txt && \
    echo 'target_link_libraries(pdf2htmlEX PRIVATE poppler)' >> pdf2htmlEX/CMakeLists.txt

RUN cd pdf2htmlEX && \
    mkdir -p build && cd build && \
    cmake .. -DCMAKE_CXX_STANDARD=11 && \
    make -j$(nproc) && \
    make install

RUN rm -rf pdf2htmlEX

CMD ["pdf2htmlEX", "--help"]
