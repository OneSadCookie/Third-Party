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

SDK_VERSION = SDK_NAME.invert

HOST = {
    'ppc' => 'powerpc',
    'ppc64' => 'powerpc64',
    'i386' => 'i686',
    'x86_64' => 'x86_64'
}

def macos_to_darwin_version(name)
    name =~ /^(\d+)\.(\d+)/
    major, minor = $1, $2
    if major.to_i == 10 then
        return minor.to_i + 4
    else
        raise "Unparseable Mac OS X version #{name}"
    end
end

def version_from_sdk_name(name)
    SDK_VERSION[name] || macos_to_darwin_version(name)
end

def existing_sdk_names
    Dir['/Developer/SDKs/MacOSX*.sdk'].map { |path|
        path =~ %r{/Developer/SDKs/MacOSX(.*)\.sdk}
        $1
    }
end

def existing_sdks
    existing_sdk_names.map { |name|
        version_from_sdk_name(name)
    }
end

def can_build_for(arch)
    existing_sdks.find { |v| v >= MIN_DARWIN_VERSION[arch] }
end

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

def compilers_for(arch, version)
    if version < 9
        return 'gcc-4.0', 'g++-4.0'
    else
        return 'gcc-4.2', 'g++-4.2'
    end
end

$subdir = ARGV[0]

ARCHS.each do |arch|
    next unless can_build_for(arch)
    
    version = version_for(arch)
    min_version = display_version_for(version)
    sdk = sdk_for(version)
    sdk_path = sdk_path(sdk)
    host = host_for(arch, version)
    cc, cxx = compilers_for(arch, version)
    system("make -C #{$subdir} " +
        "TP_CC=#{cc} " +
        "TP_CXX=#{cxx} " +
        "TP_ARCH=#{arch} " +
        "TP_SDK_PATH=#{sdk_path} " +
        "TP_MIN_VERSION=#{min_version} " +
        "TP_HOST=#{host}")
end
