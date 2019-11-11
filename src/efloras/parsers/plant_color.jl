colors = keyword("flower_color", split("""
    black(ish)? blue(ish)? brown brownish
    cream cream-yellow creamy
    crimson
    glaucous-pink gold golden golden-yellow gray gray-green green greenish
    grey grey-green
    ivory ivory-white
    lavendar lavender lemon lilac
    maroon
    olive olive-green orange orange-pink
    pink pink-purple pink-violet pinkish purple purpleish purplish
    red red-brown reddish rose rose-coloured
    salmon salmon-pink scarlet silvery? stramineous straw-colored
    sulphur-yellow
    tan
    violet violetish
    white whitish
    yellow yellowish
"""))

color_prefix = keyword("color_prefix", r"""
    bright(er)? | dark(er)? | deep(er)? | slightly | light(er)? | pale(r)?
    | usually (\s+ not)? | rarely | pale | sometimes | often
""")

color_suffix = keyword("color_suffix", split("""
    spotted spots? stripe(s|d)? vein(s|ed)? tip(s|ped)? mottled
    tinge(s|d)? longitudinal throated lined
"""))

rename = Dict(
    "blackish"      => "black",
    "blueish"       => "blue",
    "brownish"      => "brown",
    "cream"         => "white",
    "cream-yellow"  => "yellow",
    "creamy"        => "cream",
    "crimson"       => "red",
    "glaucous-pink" => "pink",
    "golden-yellow" => "yellow",
    "greyish"       => "gray",
    "greenish"      => "green",
    "ivory"         => "white",
    "lavendar"      => "purple",
    "lavender"      => "purple",
    "lemon"         => "yellow",
    "lilac"         => "purple",
    "maroon"        => "red-brown",
    "olive-green"   => "green",
    "pink-violet"   => "pink-purple",
    "pinkish"       => "pink",
    "purpleish"     => "purple",
    "purplish"      => "purple",
    "reddish"       => "red",
    "rose"          => "pink",
    "rose-coloured" => "pink",
    "salmon-pink"   => "orange-pink",
    "scarlet"       => "red",
    "silvery"       => "silver",
    "stramineous"   => "yellow",
    "straw-colored" => "yellow",
    "sulphur-yellow" => "yellow",
    "violet"        => "purple",
    "violetish"     => "purple",
    "whitish"       => "white",
    "yellowish"     => "yellow",
)

function convert(token)
end

function normalize(str)
end

function build(plant_part)
    Parser(
        name="$(plant_part)_color",
        scanners=[],
        replacers=[],
        producers=[],
    )
end

flower_color = build("flower")
