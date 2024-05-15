CONFIG=vayu_user_defconfig

ANYKERNEL=/home/ubuntu/ak3

libufdt=/home/ubuntu/libufdt

CLANG=/home/ubuntu/clang

export PATH=$CLANG/bin:$PATH

miui() {
    sed -i 's/<70>/<695>/g'     arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-36-02-0a-lcd-dsc-vid.dtsi
    sed -i 's/<154>/<1546>/g'   arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-36-02-0a-lcd-dsc-vid.dtsi
    sed -i 's/<70>/<695>/g'     arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-42-02-0b-lcd-dsc-vid.dtsi
    sed -i 's/<154>/<1546>/g'   arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-42-02-0b-lcd-dsc-vid.dtsi
}

build() {
    make -j$(nproc --all) O=out         \
    ARCH=arm64                          \
    SUBARCH=arm64                       \
    DTC_EXT=dtc                         \
    LLVM=1                              \
    LLVM_IAS=1                          \
    LD=ld.lld                           \
    AR=llvm-ar                          \
    NM=llvm-nm                          \
    STRIP=llvm-strip                    \
    OBJCOPY=llvm-objcopy                \
    OBJDUMP=llvm-objdump                \
    READELF=llvm-readelf                \
    HOSTCC=clang                        \
    HOSTCXX=clang++                     \
    HOSTAR=llvm-ar                      \
    HOSTLD=ld.lld                       \
    CROSS_COMPILE=aarch64-linux-gnu-    \
    CC="ccache clang"                   \
    REAL_CC="ccache clang"              \
    $1
}

build "$CONFIG"

build all

rm -rf $ANYKERNEL/Image* $ANYKERNEL/dtb* $ANYKERNEL/kernel.zip

cp -f out/arch/arm64/boot/Image $ANYKERNEL

find out/arch/arm64/boot/dts/qcom -name '*.dtb' -exec cat {} + > $ANYKERNEL/dtb

python3 $libufdt/utils/src/mkdtboimg.py create $ANYKERNEL/dtbo.img --page_size=4096 out/arch/arm64/boot/dts/qcom/vayu-sm8150-overlay.dtbo

miui

build dtbs

python3 $libufdt/utils/src/mkdtboimg.py create $ANYKERNEL/dtbo-miui.img --page_size=4096 out/arch/arm64/boot/dts/qcom/vayu-sm8150-overlay.dtbo

git restore arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-36-02-0a-lcd-dsc-vid.dtsi
git restore arch/arm64/boot/dts/qcom/xiaomi/overlay/common/display/dsi-panel-j20s-42-02-0b-lcd-dsc-vid.dtsi

cd $ANYKERNEL

zip -r9 kernel.zip * -x .git README.md *placeholder dtbo-miui.img
