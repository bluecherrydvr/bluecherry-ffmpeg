#!/usr/bin/make -f
STAGE = ${PWD}/stage
packageroot = ${PWD}/packageroot
path_in_package = usr/lib/bluecherry
package_version = $(shell cat packageroot/DEBIAN/control | grep Version | cut -d ' ' -f 2)
deb_file = bluecherry-ffmpeg_${package_version}_amd64.deb

.PHONY:
default: ${deb_file}

${deb_file}: ${packageroot}/${path_in_package}/ffmpeg
	dpkg-deb -b packageroot $@.tmp
	mv $@.tmp $@

.PHONY: clean
clean:
	cd ffmpeg && git clean -dxf
	# ${MAKE} -C ffmpeg distclean

	rm -rf \
		${STAGE} \
		${packageroot}/${path_in_package} \
		${deb_file} \
		;
	# git clean -dxf

ffmpeg/configure:
	git submodule update --init

ffmpeg/ffbuild/config.mak: ffmpeg/configure
	mkdir -p ${STAGE}
	cd ffmpeg && ./configure \
		--prefix=${STAGE} \
		--cc="${CC}" \
		--disable-static \
		--enable-shared \
		--enable-pic \
		--disable-stripping \
		--disable-doc \
		\
		--disable-libxcb \
		--disable-xlib \
		\
		--disable-everything \
		\
		--enable-hwaccel=h264_vaapi \
		--enable-hwaccel=hevc_vaapi \
		--enable-indev=v4l2 \
		--enable-vaapi \
		\
		--enable-protocol=file \
		--enable-protocol=http \
		--enable-protocol=https \
		--enable-protocol=pipe \
		--enable-protocol=tls \
		\
		--enable-muxer=hls \
		--enable-muxer=image2 \
		--enable-muxer=matroska \
		--enable-muxer=mjpeg \
		--enable-muxer=mp4 \
		--enable-muxer=mpegts \
		--enable-muxer=rawvideo \
		--enable-muxer=rtp \
		--enable-muxer=rtsp \
		\
		--enable-demuxer=concat \
		--enable-demuxer=matroska \
		--enable-demuxer=mjpeg \
		--enable-demuxer=rawvideo \
		--enable-demuxer=rtsp \
		\
		--enable-bsf=aac_adtstoasc \
		--enable-bsf=extract_extradata \
		--enable-bsf=h264_mp4toannexb \
		\
		--enable-decoder=aac \
		--enable-decoder=ac3 \
		--enable-decoder=h264 \
		--enable-decoder=hevc \
		--enable-decoder=mjpeg \
		--enable-decoder=mp2 \
		--enable-decoder=mp3 \
		--enable-decoder=mpeg4 \
		--enable-decoder=pcm_alaw \
		--enable-decoder=pcm_f32le \
		--enable-decoder=pcm_f64le \
		--enable-decoder=pcm_mulaw \
		--enable-decoder=pcm_s16le \
		--enable-decoder=rawvideo \
		\
		--enable-parser=h264 \
		--enable-parser=hevc \
		--enable-parser=mjpeg \
		--enable-parser=mpeg4video \
		\
		--enable-encoder=aac \
		--enable-encoder=h264_vaapi \
		--enable-encoder=hevc_vaapi \
		--enable-encoder=mjpeg \
		--enable-encoder=mjpeg_vaapi \
		--enable-encoder=mpeg4 \
		--enable-encoder=rawvideo \
		\
		--enable-filter=aevalsrc \
		--enable-filter=aresample \
		--enable-filter=fps \
		--enable-filter=hwdownload \
		--enable-filter=hwupload \
		--enable-filter=scale \
		--enable-filter=scale_vaapi \
		--enable-filter=testsrc \
		\
		;

${STAGE}/bin/ffmpeg: ffmpeg/ffbuild/config.mak
	${MAKE} ${MAKEOPTS} V=1 -C ffmpeg install

${packageroot}/${path_in_package}/ffmpeg: ${STAGE}/bin/ffmpeg
	mkdir -p ${packageroot}/${path_in_package}
	cp ${STAGE}/bin/ff* ${packageroot}/${path_in_package}
	cp -a ${STAGE}/lib/libav*.so* ${STAGE}/lib/libsw*.so* ${packageroot}/${path_in_package}
	cp -a ${STAGE}/include ${STAGE}/lib/pkgconfig ${packageroot}/${path_in_package}
