# Nalco's soup :
#
# Fixes :
# 06/07/2025 : wrongly used CMAKE_CURRENT_SOURCE_DIR instead of CMAKE_CURRENT_LIST_DIR
#
#

cmake_minimum_required(VERSION 3.30)

message("Working through VkFFT wrapper module")

project("VkFFT")

if (NOT DEFINED VULKAN_FOUND)
    find_package(Vulkan REQUIRED)
endif ()

find_package(glslang CONFIG REQUIRED)


message(STATUS "Running VkFFT's configure.sh...")
execute_process(
        COMMAND bash "${CMAKE_CURRENT_LIST_DIR}/configure.sh"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
        RESULT_VARIABLE _res
)
if (NOT _res EQUAL 0)
    message(FATAL_ERROR "configure.sh failed with code ${_res}")
endif ()


if (NOT DEFINED VKFFT_DIM)
    set(VKFFT_DIM "2" CACHE STRING "Max FFT dimensions")
endif ()

if (NOT DEFINED VKFFT_BACKEND)
    set(VKFFT_BACKEND "0" CACHE STRING "VkFFT's Backend : 0-Vulkan")
endif ()

set(ENABLE_OPT 0)

add_library(VkFFT INTERFACE)

target_include_directories(VkFFT INTERFACE
        ${CMAKE_CURRENT_LIST_DIR}/external/VkFFT/
)

target_compile_definitions(VkFFT INTERFACE
        VKFFT_MAX_FFT_DIMENSIONS=${VKFFT_DIM}
        VKFFT_BACKEND=${VKFFT_BACKEND}
)

target_link_libraries(VkFFT
        INTERFACE
        glslang::SPIRV
        glslang::glslang
        Vulkan::Vulkan
        glslang::glslang-default-resource-limits
)