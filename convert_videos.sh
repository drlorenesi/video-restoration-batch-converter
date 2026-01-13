#!/bin/bash

# Video Restoration Batch Converter with Upscaling
# Usage: ./convert_videos.sh [input_folder] [output_folder]

# Trap Ctrl+C (SIGINT) and clean up
trap ctrl_c INT

function ctrl_c() {
    echo ""
    echo ""
    echo "========================================="
    echo "Conversion cancelled by user"
    echo "========================================="
    echo "Processed $current of $total_files files before cancellation."
    echo "Partially converted files may exist in: $OUTPUT_FOLDER"
    exit 130
}

# Set default folders
INPUT_FOLDER="${1:-.}"  # Default to current directory if not specified
OUTPUT_FOLDER="${2:-./converted}"  # Default to ./converted if not specified

# Ask user for resolution preference
echo "========================================="
echo "Video Restoration Batch Converter"
echo "========================================="
echo ""
echo "Please select resolution option:"
echo "  1) Keep original resolution (no upscaling)"
echo "  2) Upscale to 720p (1280x720)"
echo "  3) Upscale to 1080p (1920x1080)"
echo ""
read -p "Enter your choice (1-3): " choice

# Set resolution based on user choice
case "$choice" in
    1)
        RESOLUTION="original"
        ;;
    2)
        RESOLUTION="720p"
        ;;
    3)
        RESOLUTION="1080p"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Set scale filter based on resolution
echo ""
if [ "$RESOLUTION" = "720p" ]; then
    SCALE_FILTER="scale=1280:-2:flags=lanczos,"
    echo "Selected: Upscale to 720p (1280x720)"
elif [ "$RESOLUTION" = "1080p" ]; then
    SCALE_FILTER="scale=1920:-2:flags=lanczos,"
    echo "Selected: Upscale to 1080p (1920x1080)"
else
    SCALE_FILTER=""
    echo "Selected: Keep original resolution"
fi
echo ""

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Counter for progress
total_files=$(find "$INPUT_FOLDER" -maxdepth 1 \( -iname "*.wmv" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.asf" \) | wc -l | tr -d ' ')
current=0

echo "Found $total_files video files to convert"
echo "Input folder: $INPUT_FOLDER"
echo "Output folder: $OUTPUT_FOLDER"
echo ""
echo "Press Ctrl+C at any time to cancel"
echo "----------------------------------------"

# Loop through all video files in the input folder
for input_file in "$INPUT_FOLDER"/*.{wmv,avi,mkv,mov,mpg,mpeg,WMV,AVI,MKV,MOV,MPG,MPEG,asf}; do
    # Skip if no files match the pattern
    [ -e "$input_file" ] || continue
    
    # Get filename without path and extension
    filename=$(basename "$input_file")
    filename_no_ext="${filename%.*}"
    
    # Output file path (add resolution suffix if upscaling)
    if [ "$RESOLUTION" = "original" ]; then
        output_file="$OUTPUT_FOLDER/${filename_no_ext}.mp4"
    else
        output_file="$OUTPUT_FOLDER/${filename_no_ext}_${RESOLUTION}.mp4"
    fi
    
    # Increment counter
    ((current++))
    
    echo ""
    echo "[$current/$total_files] Converting: $filename"
    echo "Output: $(basename "$output_file")"
    
    # Run FFmpeg conversion with dynamic scale filter
    # Note: For faster encoding on Mac (2-4x faster), use hardware acceleration by:
    # 1. Commenting out the next two lines (libx264 and tune film)
    # 2. Uncommenting the h264_videotoolbox line below
    
    ffmpeg -fflags +genpts+igndts -i "$input_file" \
        -err_detect ignore_err \
        -max_error_rate 1.0 \
        -vf "${SCALE_FILTER}hqdn3d=2:1:3:2,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1,format=yuv420p" \
        -c:v libx264 -preset slow -crf 22 \
        -tune film \
        -c:a aac -b:a 128k \
        -async 1 \
        -af aresample=async=1:first_pts=0 \
        -max_muxing_queue_size 9999 \
        -movflags +faststart \
        "$output_file" \
        -hide_banner -loglevel error -stats
    
    # Hardware acceleration version (comment out the ffmpeg command above and uncomment below):
    # ffmpeg -fflags +genpts+igndts -i "$input_file" \
    #     -err_detect ignore_err \
    #     -max_error_rate 1.0 \
    #     -vf "${SCALE_FILTER}hqdn3d=2:1:3:2,unsharp=luma_msize_x=7:luma_msize_y=7:luma_amount=1,format=yuv420p" \
    #     -c:v h264_videotoolbox -b:v 6M \
    #     -color_range pc \
    #     -c:a aac -b:a 128k \
    #     -async 1 \
    #     -af aresample=async=1:first_pts=0 \
    #     -max_muxing_queue_size 9999 \
    #     -movflags +faststart \
    #     "$output_file" \
    #     -hide_banner -loglevel error -stats
    
    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        echo "✓ Successfully converted: $filename"
    else
        echo "✗ Failed to convert: $filename"
    fi
done

echo ""
echo "----------------------------------------"
echo "Conversion complete! Processed $current files."
echo "Converted files are in: $OUTPUT_FOLDER"
