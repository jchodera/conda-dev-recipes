#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    CUDA_PATH="/usr/local/cuda-7.5"
    CMAKE_FLAGS+=" -DCUDA_CUDART_LIBRARY=${CUDA_PATH}/lib64/libcudart.so"
    CMAKE_FLAGS+=" -DCUDA_NVCC_EXECUTABLE=${CUDA_PATH}/bin/nvcc"
    CMAKE_FLAGS+=" -DCUDA_SDK_ROOT_DIR=${CUDA_PATH}/"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_INCLUDE=${CUDA_PATH}/include"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_PATH}/"
    #CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=/opt/AMDAPPSDK-2.9-1/include/"
    #CMAKE_FLAGS+=" -DOPENCL_LIBRARY=/opt/AMDAPPSDK-2.9-1/lib/x86_64/libOpenCL.so"
    CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS_RELEASE=-I/usr/include/nvidia/"
    CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DUR=${CUDA_PATH}/include/"
    CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${CUDA_PATH}/lib64/libOpenCL.so"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9"
    CMAKE_FLAGS+=" -DCUDA_SDK_ROOT_DIR=/Developer/NVIDIA/CUDA-7.5"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-7.5"
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"
fi

# Generate API docs
CMAKE_FLAGS+=" -DOPENMM_GENERATE_API_DOCS=ON"

# Set location for FFTW3 on both linux and mac
CMAKE_FLAGS+=" -DFFTW_INCLUDES=$PREFIX/include"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.so"
    CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.so"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.dylib"
    CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.dylib"
fi

# Build in subdirectory.
mkdir build
cd build
cmake .. $CMAKE_FLAGS
cat ../CMakeCache.txt # DEBUG
make -j$CPU_COUNT all
make -j$CPU_COUNT install PythonInstall

# Clean up paths
mkdir openmm-docs
mv $PREFIX/docs/* openmm-docs
mv openmm-docs $PREFIX/docs/openmm

# Build manuals
make -j$CPU_COUNT sphinxpdf
#mkdir -p $PREFIX/docs/openmm/userguide
mv sphinx-docs/userguide/latex/*.pdf $PREFIX/docs/openmm/
mv sphinx-docs/developerguide/latex/*.pdf $PREFIX/docs/openmm/
# Build API docs
#make -j$CPU_COUNT C++ApiDocs PythonApiDocs
#mv api-python $PREFIX/docs/openmm
#mv api-c++ $PREFIX/docs/openmm
# Move errant .html files
#mv $PREFIX/docs/"Python API Reference.html" $PREFIX/docs/openmm
#mv $PREFIX/docs/"C++ API Reference.html" $PREFIX/docs/openmm

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/
