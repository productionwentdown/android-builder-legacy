# Android Dockerfile based on uber/android-build-environment

FROM ubuntu:16.04

# SDK version
ENV ANDROID_SDK_VERSION 3859397

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive

# Update apt-get
RUN apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
      software-properties-common \
      unzip \
      wget \
      zip \
      make \
  && apt-add-repository ppa:openjdk-r/ppa \
  && apt-get -qq update \
  && apt-get -qq install -y openjdk-8-jdk \
      -o Dpkg::Options::="--force-overwrite" \
  && apt-get -qq autoremove -y \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/*

# Install Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_VERSION.zip -q \
  && mkdir /usr/local/android \
  && unzip -q sdk-tools-linux-$ANDROID_SDK_VERSION.zip -d /usr/local/android \
  && rm sdk-tools-linux-$ANDROID_SDK_VERSION.zip

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Environment variables
ENV ANDROID_HOME /usr/local/android
ENV ANDROID_SDK_HOME $ANDROID_HOME
ENV ANDROID_NDK_HOME $ANDROID_HOME/ndk-bundle
ENV PATH $ANDROID_HOME/tools/bin:$PATH

# Install Android SDK components
RUN yes | sdkmanager --licenses
RUN sdkmanager \
  "tools" \
  "ndk-bundle" \
#  "lldb;2.3" \
#  "cmake;3.6.4111459" \
  "platform-tools" \
  "platforms;android-27" \
  "build-tools;27.0.3"

# Build directory
ENV SRC /src
RUN mkdir $SRC
WORKDIR $SRC

RUN echo "sdk.dir=$ANDROID_SDK_HOME" >> local.properties
RUN echo "ndk.dir=$ANDROID_NDK_HOME" >> local.properties

CMD ["./gradlew", "build"]
