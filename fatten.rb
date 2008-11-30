#!/usr/bin/ruby

require 'digest/md5'
require 'fileutils'
require 'find'

ARCHS = [ 'ppc', 'i386', 'ppc64', 'x86_64' ]

def arch_of(path)
    s = `lipo -info "#{path}" 2>/dev/null`
    if $?.success? then
        s =~ /.*: (.*)/
        $1
    else
        nil
    end
end

def is_text(path)
    `mdls -name kMDItemContentTypeTree '#{path}' | grep 'public\\.text'`
    $?.success?
end

$files = {}
ARCHS.each do |arch|
    base = "install/#{arch}/"
    $files[arch] = {}
    Find.find(base) do |path|
        next unless File.file?(path)
        file = path[base.length..-1]
        $files[arch][file] = {
            :md5 => Digest::MD5.file(path).to_s,
            :arch => arch_of(path),
            :text => is_text(path),
        }
    end
end

all_files = ARCHS.map { |arch| $files[arch].keys }.flatten.sort.uniq

all_files.each do |file|
    files = ARCHS.map { |arch| $files[arch][file] }.compact
    
    if files.size != ARCHS.size then
        puts "Not all architectures have #{file}; don't know what to do."
    elsif files.all? { |f| f[:md5] == files[0][:md5] } then
        dest_dir = "fat/#{File.dirname(file)}"
        FileUtils.mkdir_p(dest_dir)
        FileUtils.cp("install/ppc/#{file}", dest_dir)
    elsif files[0][:arch] then
        dest_dir = "fat/#{File.dirname(file)}"
        FileUtils.mkdir_p(dest_dir)
        inputs = ARCHS.map { |arch| "install/#{arch}/#{file}" }
        system("lipo #{inputs.join(' ')} -create -output #{dest_dir}/#{File.basename(file)}")
    else
        puts "File #{file} differs between architectures, but I don't know" +
            " how to merge it."
    end
end
