# http://blog.internautdesign.com/2008/4/21/simple-linear-regression-best-fit
class LinearRegression
  attr_accessor :slope, :offset, :r2

  def initialize dx, dy=nil
    @size = dx.size
    dy,dx = dx,axis() unless dy  # make 2D if given 1D
    raise "arguments not same length!" unless @size == dy.size
    sxx = sxy = syy = sx = sy = 0
    dx.zip(dy).each do |x,y|
      sxy += x*y
      sxx += x*x
      syy += y*y
      sx  += x
      sy  += y
    end
    @slope = ( @size * sxy - sx*sy ) / ( @size * sxx - sx * sx )
    @offset = (sy - @slope*sx) / @size
    @r2 = ( @size * sxy - sx*sy ) * ( @size * sxy - sx*sy ) / ( ( @size * sxx - sx * sx ) * ( @size * syy - sy * sy ) )
  end

  def fit
    return axis.map{|data| predict(data) }
  end

  def predict( x )
    y = @slope * x + @offset
  end

  def axis
    (0...@size).to_a
  end
end
