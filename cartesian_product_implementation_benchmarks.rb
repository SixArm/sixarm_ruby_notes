#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-


=begin

Compare three implemenations of cartesian product.
The winner is Enumerable.cartesian_product_impl_with_each

BENCHMARK RESULTS
                                         user     system      total        real
2 16 each                            0.220000   0.000000   0.220000 (  0.223156)
2 16 recursion                       0.240000   0.010000   0.250000 (  0.251840)
2 16 inject                          0.260000   0.010000   0.270000 (  0.264444)

6 7 each                             0.430000   0.010000   0.440000 (  0.445227)
6 7 recursion                        0.580000   0.010000   0.590000 (  0.588128)
6 7 inject                           0.850000   0.020000   0.870000 (  0.865519)

25 4 each                            0.510000   0.000000   0.510000 (  0.507598)
25 4 recursion                       0.610000   0.000000   0.610000 (  0.616778)
25 4 inject                          1.060000   0.030000   1.090000 (  1.090755)

800 2 each                           0.860000   0.000000   0.860000 (  0.856841)
800 2 recursion                      0.980000   0.000000   0.980000 (  0.978946)
800 2 inject                        29.680000   1.150000  30.830000 ( 31.037944)


SYSTEM INFO

$ ruby -v
ruby 1.8.6 (2008-08-11 patchlevel 287) [i686-linux]

$ uname -a
Linux joelparkerhenderson 2.6.27-14-generic #1 SMP Wed Apr 15 18:59:16 UTC 2009 i686 GNU/Linux


=end


module Enumerable


  # Return the cartesian product of the enumerations.
  # This implementaion uses a double-nested each loop
  # It returns results in typical order.
  # By William James.
  # See http://www.ruby-forum.com/topic/95519

  def self.cartesian_product_impl_with_each(*enums)
    result = [[]]
    while [] != enums
      t, result = result, []
      b, *enums = enums
      t.each do |a|
        b.each do |n|
          result << a + [n]
        end
      end
    end
   result
  end


  # Return the cartesian product of the enumerations.
  # This implementaion uses a double-nested each loop.
  # It returns results in typical order.
  #
  # By Brian Schröäer, with a method signature modification for compatibility.
  # See http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/151857

  def self.cartesian_product_impl_with_recursion(*enums)
    first=enums.shift
    return first.map{|a| [a] } if enums.empty?
    enums = self.cartesian_product_impl_with_recursion(*enums)
    first.inject([]) { | r, a | enums.inject(r) { | r, b | r << ([a, *b]) } }
  end


  # Return the cartesian product of the enumerations.
  # This implementation uses a double-nested inject loop;
  # it returns results in atypical order: right-to-left.
  #
  # By William James.
  # See http://www.ruby-forum.com/topic/95519

  def self.cartesian_product_impl_with_inject(*enums)
    enums.inject([[]]){|old,lst|
      lst.inject([]){|new,e|
        new + old.map{|c| c.dup << e}}}
  end


end

require 'benchmark'

Benchmark.bm(35) do | b | 
  [[2, 16], [6,7], [25,4], [800,2]].each do | size, depth |
    args = Array.new(depth) { Array.new(size) {|i| i} }    
    b.report("#{size} #{depth} each") do Enumerable.cartesian_product_impl_with_each(*args) end
    b.report("#{size} #{depth} recursion") do Enumerable.cartesian_product_impl_with_recursion(*args) end
    b.report("#{size} #{depth} inject") do Enumerable.cartesian_product_impl_with_inject(*args) end
    puts
  end
end


