VKFFT_REPO="https://github.com/DTolm/VkFFT.git"
VKFFT_REMOTEHASH_LOCATION="https://api.github.com/repos/DTolm/VkFFT/commits/master"
DO_CLEAN=false

# ----------- HELP TEXT -------------

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
	echo -e "\033[0;31m\n\t---     VKFFT FOR MODERN CMAKE     ---\n\033[0m"
    echo "Usage: ./configure.sh [--refresh]"
    echo
    echo "Options:"
	echo "  -r, --refresh  Show this help message"
    echo "  -h, --help  Show this help message"
    echo
    exit 0
fi

# ----------- PARSE ARGUMENTS -------------

for arg in "$@"; do
    case "$arg" in -r|--refresh)
            DO_CLEAN=true
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [debug|release] [--clean]"
            exit 1
            ;;
    esac
done

# ----------- CLEAN IF REQUESTED -------------

if $DO_CLEAN; then
    echo -e "\033[1;32m\n--- Cleaning external files\033[0m"

    for DIR in external  temp_vkfft_clone; do
        if [ -d "$DIR" ]; then
            echo "Removing $DIR..."
            rm -rf "$DIR" || echo "Failed to remove $DIR. It may be in use or locked."
        fi
    done
fi

mkdir -p external/

remote_hash=$(curl -s $VKFFT_REMOTEHASH_LOCATION | jq -r '.sha')

if [ ! -f external/VkFFT/vkFFT.h ]; then
    mkdir -p external/VkFFT

    #testing for internet connection
    echo -e "\033[1;32m\n--- Cloning minimal VkFFT ---\033[0m"
    if git clone --depth 1 --filter=blob:none --sparse "$VKFFT_REPO" temp_vkfft_clone; then
		echo -e "\033[1;32mClone successful\033[0m"
	else
		echo -e "\033[1;31mClone failed\033[0m"
		exit 2
	fi

	#CLEANUP
    cd temp_vkfft_clone || exit 1
	echo -e "\033[1;32m\n--- Cleaning up unwanted files\033[0m"
    git sparse-checkout set vkFFT
    mv vkFFT ../external/
    cd ..
    rm -rf temp_vkfft_clone

    #storing version for update check !
    echo "$remote_hash" > .version

	echo -e "\033[1;32m\n--- Patching files for modern CMake usage ---\033[0m"
    #now replacing unorthodox references to glslang includes (with all due respect to DTolm
    d=$'\03'
    ogGciHeaderStr="\"glslang_c_interface.h\""
    newGciHeaderStr="<glslang/Include/glslang_c_interface.h>"

    find external/VkFFT -type f -name '*.h' | while read -r filename; do
		[ -e "$filename" ] || continue
		if grep -qF "$ogGciHeaderStr" "$filename"; then
			sed -i -e "s#$ogGciHeaderStr#$newGciHeaderStr#g" "$filename"
			echo "patching : "$filename
		fi
	done

	echo -e "\033[1;33m\n--- Done !\033[0m"

    else
    echo -e "\033[1;32m\n--- VkFFT already present, skipping clone ---\033[0m"

    # Check for updates
	local_hash=$(cat .version)

	if [ -z "$remote_hash" ]; then
		echo -e "\033[0;33m No internet connection or GitHub is unreachable. Skipping update check.\033[0m"
		exit 2
	fi

	if [ "$remote_hash" != "$local_hash" ]; then
		echo -e "\033[0;33m Update available! To update, run :  $PWD/configure.sh -r \033[0m"
	else
		echo "Already up to date."
	fi
fi
