message('pot/filters submenu')

##############

xml_sources_filters_animation = [
    'blend.xml',
    'burn-in.xml',
    'optimize.xml',
    'playback.xml',
    'rippling.xml',
    'spinning-globe.xml',
    'waves.xml',
]
pot_filters_animation = 'animation.pot'

input_xml  = xml_sources_filters_animation
output_pot = pot_filters_animation

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/animation/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_animation_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_artistic = [
    'applycanvas.xml',
    'cartoon.xml',
    'clothify.xml',
    'cubism.xml',
    'GIMPressionist-orientmap.xml',
    'GIMPressionist-sizemap.xml',
    'GIMPressionist.xml',
    'glasstile.xml',
    'introduction.xml',
    'oilify.xml',
    'photocopy.xml',
    'simple-linear-clustering.xml',
    'softglow.xml',
    'vangogh-lic.xml',
    'waterpixels.xml',
    'weave.xml',
]
pot_filters_artistic = 'artistic.pot'

input_xml  = xml_sources_filters_artistic
output_pot = pot_filters_artistic

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/artistic/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_artistic_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_blur = [
    'circular-motion.xml',
    'focus-blur.xml',
    'gauss.xml',
    'gauss_select.xml',
    'introduction.xml',
    'lens-blur.xml',
    'linear-motion.xml',
    'mean-curvature-blur.xml',
    'median-blur.xml',
    'pixelize.xml',
    'tileable.xml',
    'variable-blur.xml',
    'zoom-motion.xml',
]
pot_filters_blur = 'blur.pot'

input_xml  = xml_sources_filters_blur
output_pot = pot_filters_blur

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/blur/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_blur_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_combine = [
    'depthmerge.xml',
    'filmstrip.xml',
    'introduction.xml',
]
pot_filters_combine = 'combine.pot'

input_xml  = xml_sources_filters_combine
output_pot = pot_filters_combine

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/combine/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_combine_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_decor = [
    'add-bevel.xml',
    'addborder.xml',
    'carve-it.xml',
    'chrome-it.xml',
    'fog.xml',
    'fuzzyborder.xml',
    'introduction.xml',
    'old-photo.xml',
    'round-corners.xml',
    'slide.xml',
    'stain.xml',
]
pot_filters_decor = 'decor.pot'

input_xml  = xml_sources_filters_decor
output_pot = pot_filters_decor

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/decor/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_decor_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_distort = [
    'apply_lens.xml',
    'blinds.xml',
    'curve_bend.xml',
    'emboss.xml',
    'engrave.xml',
    'introduction.xml',
    'kaleidoscope.xml',
    'lens-distortion.xml',
    'mosaic.xml',
    'newsprint.xml',
    'pagecurl.xml',
    'polarcoords.xml',
    'ripple.xml',
    'shift.xml',
    'spherize.xml',
    'video-degradation.xml',
    'vpropagate.xml',
    'waves.xml',
    'whirlpinch.xml',
    'wind.xml',
]
pot_filters_distort = 'distort.pot'

input_xml  = xml_sources_filters_distort
output_pot = pot_filters_distort

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/distort/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_distort_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_edge = [
    'dog.xml',
    'edge_detect.xml',
    'image_gradient.xml',
    'introduction.xml',
    'laplace.xml',
    'neon.xml',
    'sobel.xml',
]
pot_filters_edge = 'edge-detect.pot'

input_xml  = xml_sources_filters_edge
output_pot = pot_filters_edge

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/edge-detect/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_edge_detect_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_enhance = [
    'antialias.xml',
    'deinterlace.xml',
    'despeckle.xml',
    'high-pass.xml',
    'introduction.xml',
    'nl-filter.xml',
    'noise-reduction.xml',
    'red-eye-removal.xml',
    'symmetric-nearest-neighbor.xml',
    'unsharp_mask.xml',
    'wavelet-decompose.xml',
]
pot_filters_enhance = 'enhance.pot'

input_xml  = xml_sources_filters_enhance
output_pot = pot_filters_enhance

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/enhance/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_enhance_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_generic = [
    'convol-matrix.xml',
    'dilate.xml',
    'distance-map.xml',
    'erode.xml',
    'gegl-graph.xml',
    'gegl-styles.xml',
    'introduction.xml',
    'normal-map.xml',
]
pot_filters_generic = 'generic.pot'

input_xml  = xml_sources_filters_generic
output_pot = pot_filters_generic

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/generic/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_generic_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_light = [
    'bloom.xml',
    'drop-shadow-legacy.xml',
    'drop-shadow.xml',
    'gegl-bevel.xml',
    'gegl-inner-glow.xml',
    'gflare.xml',
    'introduction.xml',
    'lens-flare.xml',
    'lighting.xml',
    'long-shadow.xml',
    'perspective-shadow.xml',
    'sparkle.xml',
    'supernova.xml',
    'vignette.xml',
    'xach-effect.xml',
]
pot_filters_light = 'light-and-shadow.pot'

input_xml  = xml_sources_filters_light
output_pot = pot_filters_light

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/light-and-shadow/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_light_and_shadow_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_map = [
    'bumpmap.xml',
    'displace.xml',
    'fractal-trace.xml',
    'illusion.xml',
    'introduction.xml',
    'little-planet.xml',
    'map-object.xml',
    'panorama-projection.xml',
    'papertile.xml',
    'recursive-transform.xml',
    'smalltiles.xml',
    'tile-seamless.xml',
    'tile.xml',
    'warp.xml',
]
pot_filters_map = 'map.pot'

input_xml  = xml_sources_filters_map
output_pot = pot_filters_map

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/map/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_map_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_noise = [
    'cie-lch-noise.xml',
    'hsv-noise.xml',
    'hurl.xml',
    'introduction.xml',
    'pick.xml',
    'rgb-noise.xml',
    'slur.xml',
    'spread.xml',
]
pot_filters_noise = 'noise.pot'

input_xml  = xml_sources_filters_noise
output_pot = pot_filters_noise

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/noise/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_noise_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_render = [
    'bayer-matrix.xml',
    'cell-noise.xml',
    'checkerboard-legacy.xml',
    'checkerboard.xml',
    'circuit.xml',
    'cmlexplorer.xml',
    'difference-clouds.xml',
    'diffraction.xml',
    'flame.xml',
    'fractalexplorer.xml',
    'gfig.xml',
    'grid-legacy.xml',
    'grid.xml',
    'ifsfractal.xml',
    'introduction.xml',
    'jigsaw.xml',
    'lava.xml',
    'line-nova.xml',
    'linear-sinusoid.xml',
    'maze.xml',
    'perlin-noise.xml',
    'plasma.xml',
    'qbist.xml',
    'simplex-noise.xml',
    'sinus.xml',
    'solid-noise.xml',
    'spheredesigner.xml',
    'spiral.xml',
    'spyrogimp.xml',
]
pot_filters_render = 'render.pot'

input_xml  = xml_sources_filters_render
output_pot = pot_filters_render

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/render/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_render_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

##############

xml_sources_filters_web = [
    'imagemap.xml',
    'semiflatten.xml',
]
pot_filters_web = 'web.pot'

input_xml  = xml_sources_filters_web
output_pot = pot_filters_web

input_files = []
input_base_dir = meson.project_source_root() + '/src/filters/web/'
output_dir     = meson.project_build_root()  + '/pot/filters'

foreach xml_file: input_xml
    input_files += input_base_dir + xml_file
endforeach

filters_web_pot = custom_target(output_pot,
    depends: [copy_authors_to_src],
    depend_files: [input_files],
    output: [output_pot],
    command: [
        xml2pot, output_pot, output_dir, meson.project_source_root(), input_files,
    ],
)

