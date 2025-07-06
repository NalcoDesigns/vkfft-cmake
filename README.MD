# Why not using VkFFT directly

VkFFT requires you to download, build and link a bunch of dependencies, which my package avoids, by simply allowing you to use prebuilt libraries.
(For now it only works with Vulkan)
# VkFFT CMake module

This project provides a lightweight CMake wrapper for [VkFFT](https://github.com/DTolm/VkFFT), designed to be easily included in your CMake-based project via `FetchContent`.

* Downloads the latest VkFFT source code
* Applies Include patches (to link towards prebuilt glslang headers)
* Detects upstream updates automatically and prompts you if a VkFFT update is available
* Re-applies Include patches if needed

> [!NOTE]
> Patches only glslang includes

## Usage

In your `CMakeLists.txt`:

```cmake
include(FetchContent)

FetchContent_Declare(
    NVkFFT
    GIT_REPOSITORY https://github.com/NalcoDesigns/vkfft-cmake.git
    GIT_TAG main
)

FetchContent_MakeAvailable(NVkFFT)

target_link_libraries(ProjectName [PUBLIC|PRIVATE] NVkFFT)
```

Once included, the `VkFFT` source will be available in your project, ready for use or building as a static library.


## Requirements

* CMake ≥ 3.14 & git
* Already installed glslang / Vulkan SDK
---

## License

This wrapper is MIT-licensed. VkFFT itself is licensed under its own terms. Please refer to the [VkFFT repository](https://github.com/DTolm/VkFFT) for details.

