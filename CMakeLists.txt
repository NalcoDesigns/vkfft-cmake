#add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/external/glslang_dep)
cmake_minimum_required(VERSION 3.30)

message("Working through VkFFT wrapper module")

project("VkFFT")

if (NOT DEFINED VULKAN_FOUND)
    find_package(Vulkan REQUIRED)
endif ()

find_package(glslang CONFIG REQUIRED)

set(FILE_CHECK "${CMAKE_CURRENT_SOURCE_DIR}/external/vkFFT/vkFFT.h")
message(STATUS "Running vkfft configure.sh...")
execute_process(
        COMMAND bash "${CMAKE_CURRENT_LIST_DIR}/configure.sh"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        RESULT_VARIABLE _res
)
if (NOT _res EQUAL 0)
    message(FATAL_ERROR "configure.sh failed with code ${_res}")
endif ()


if (NOT DEFINED VKFFT_DIM)
    set(VKFFT_BACKEND "2")# don't need more than 2D by default
endif ()

if (NOT DEFINED VKFFT_BACKEND)
    set(VKFFT_BACKEND "0") #0 = vulkan
endif ()

set(ENABLE_OPT 0)

add_definitions(-DVKFFT_MAX_FFT_DIMENSIONS=${VKFFT_DIM})
add_definitions(-DVKFFT_BACKEND=${VKFFT_BACKEND})


add_library(VKFFT INTERFACE)

target_include_directories(VKFFT
        #PUBLIC
        #${CMAKE_CURRENT_SOURCE_DIR}
        #${CMAKE_CURRENT_SOURCE_DIR}/external/VkFFT/VkFFT/vkFFT_Structs
        INTERFACE #PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/external/VkFFT/
)

target_link_libraries(VKFFT
        INTERFACE
        glslang::SPIRV
        glslang::glslang
        Vulkan::Vulkan
        glslang::glslang-default-resource-limits
)
