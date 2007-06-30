ARCHS = [ 'ppc', 'ppc64', 'i386', 'x86_64' ]

MIN_DARWIN_VERSION = {
    'ppc'    => 7,
    'i386'   => 8,
    'ppc64'  => 9,
    'x86_64' => 9
}

SDK_NAME = {
    7 => '10.3.9',
    8 => '10.4u',
}

HOST = {
    'ppc' => 'powerpc',
    'ppc64' => 'powerpc64',
    'i386' => 'i686',
    'x86_64' => 'x86_64'
}

MAX_DARWIN_VERSION = 9

def display_version_for(darwin_version)
    "10.#{darwin_version - 4}"
end

def sdk_for(darwin_version)
    SDK_NAME[darwin_version] || display_version_for(darwin_version)
end

def sdk_path(sdk)
    "/Developer/SDKs/MacOSX#{sdk}.sdk"
end

def version_for(arch)
    min_version = MIN_DARWIN_VERSION[arch]
    version = min_version
    sdk = sdk_for(version)
    while !File.exists?(sdk_path(sdk)) do
        version += 1
        sdk = sdk_for(version)
    end
    version
end

def host_for(arch, version)
    "#{HOST[arch]}-apple-darwin#{version}"
end

$subdir = ARGV[0]

ARCHS.each do |arch|
    version = version_for(arch)
    min_version = display_version_for(version)
    sdk = sdk_for(version)
    sdk_path = sdk_path(sdk)
    host = host_for(arch, version)
    system("make -C #{$subdir} " +
        "TP_ARCH=#{arch} " +
        "TP_SDK_PATH=#{sdk_path} " +
        "TP_MIN_VERSION=#{min_version} " +
        "TP_HOST=#{host}")
end
