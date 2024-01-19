defmodule Derivative do
  @type literal() :: {:num, number()} | {:var, atom()}
  @type expr() :: literal()
  | {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:exp, expr(), literal()}
  | {:sin, expr()}
  | {:cos, expr()}
  | {:ln, expr()}

  def test1() do
    e = {:add,
          {:mul, {:num, 7}, {:var, :x}},
          {:num, 8}}
    d = deriv(e, :x)
    c = calc(d, :x, 5)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n\n")
    :ok
  end

  def test2() do
    e = {:add,
          {:exp, {:var, :x}, {:num, 2}},
          {:num, 4}}
    d = deriv(e, :x)
    c = calc(d, :x, 4)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n\n")
    :ok
  end

  def test3() do
    e = {:exp,
          {:sin, {:mul, {:num, 2}, {:var, :x}}}, {:num, -1}}
    d = deriv(e, :x)
    c = calc(d, :x, 4)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def test4() do
    e = {:ln,
          {:mul, {:num, 2}, {:var, :x}}}
    d = deriv(e, :x)
    c = calc(d, :x, 1)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def test5() do
    e = {:exp,
          {:mul, {:num, 2}, {:var, :x}}, {:num, 0.5}}
    d = deriv(e, :x)
    c = calc(d, :x, 2)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def test6() do
    e = {:sin,
          {:num, 0}}
    d = deriv(e, :x)
    c = calc(d, :x, 2)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(d))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def test7() do
    e = {:mul,
          {:num, 2},{:add, {:mul, {:num, 2}, {:var, :x}}, {:num, 1}}}
    d = deriv(e, :x)
    c = calc(d, :x, 2)
    IO.write("expression: #{pprint(e)}\n")
    IO.write("derivative: #{pprint(d)}\n")
    IO.write("simplified: #{pprint(simplify(e))}\n")
    IO.write("calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def deriv({:num, _}, _) do {:num, 0} end
  def deriv({:var, v}, v) do {:num, 1} end
  def deriv({:var, _}, _) do {:num, 0} end
  def deriv({:add, e1, e2}, v) do
    {:add, deriv(e1, v), deriv(e2, v)}
  end
  def deriv({:mul, e1, e2}, v) do
    {:add,
      {:mul, deriv(e1, v), e2},
      {:mul, e1, deriv(e2, v)}}
  end
  def deriv({:exp, e, {:num, n}}, v) do
    {:mul,
      {:mul, {:num, n}, {:exp, e, {:num, n-1}}},
      deriv(e, v)}
  end

  def deriv({:sin, e}, v) do
    if is_number(e) do
      {:cos, e}
    else
    {:mul,
      {:cos, e}, deriv(e,v)}
    end
  end

  def deriv({:ln, e}, v) do
    {:mul,
      {:exp, e, {:num, -1}}, deriv(e,v)}
  end


  def calc({:num, n}, _, _) do {:num, n} end
  def calc({:var, v}, v, n) do {:num, n} end
  def calc({:var, v}, _, _) do {:var, v} end
  def calc({:add, e1, e2}, v, n) do
    {:add, calc(e1, v, n), calc(e2, v, n)}
  end
  # show (num * var) as a calculated num
  def calc({:mul, {:num, n1}, {:var, v}}, v, n) do
    {:num, n*n1}
  end
  def calc({:mul, e1, e2}, v, n) do
    {:mul, calc(e1, v, n), calc(e2, v, n)}
  end
  def calc({:exp, e1, e2}, v, n) do
    {:exp, calc(e1, v, n), calc(e2, v, n)}
  end
  def calc({:sin, e}, v, n) do
    {:sin, calc(e, v, n)}
  end
  def calc({:cos, e}, v, n) do
    {:cos, calc(e, v, n)}
  end
  def calc({:ln, e}, v, n) do
    {:ln, calc(e, v, n)}
  end


  def simplify({:add, e1, e2}) do
    simplify_add(simplify(e1), simplify(e2))
  end
  def simplify({:mul, e1, e2}) do
    simplify_mul(simplify(e1), simplify(e2))
  end
  def simplify({:exp, e1, e2}) do
    simplify_exp(simplify(e1), simplify(e2))
  end
  def simplify({:sin, e}) do
    simplify_sin(simplify(e))
  end
  def simplify({:cos, e}) do
    simplify_cos(simplify(e))
  end
  def simplify({:ln, e}) do
    simplify_ln(simplify(e))
  end
  def simplify(e) do e end

  def simplify_add({:num, 0}, e2) do e2 end
  def simplify_add(e1, {:num, 0}) do e1 end
  def simplify_add(e1, e2) do {:add, e1, e2} end

  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul(_, {:num, 0}) do {:num, 0} end
  def simplify_mul({:num, 1}, e2) do e2 end
  def simplify_mul(e1, {:num, 1}) do e1 end
  def simplify_mul({:num, -1}, {:num, n2}) do {:num, -n2} end
  def simplify_mul({:num, n1}, {:num, -1}) do {:num, -n1} end
  def simplify_mul({:num, n1}, {:num, n2}) do {:num, n1*n2} end
  def simplify_mul(e1, e2) do {:mul, e1, e2} end

  def simplify_exp(_,{:num, 0}) do {:num, 1} end
  def simplify_exp(e1, {:num, 1}) do e1 end
  def simplify_exp({:num, n1}, {:num, n2}) do {:num, :math.pow(n1, n2)} end
  def simplify_exp(e1, e2) do {:exp, e1, e2} end

  def simplify_sin({:num, n}) do {:num, :math.sin(n)} end
  def simplify_sin(e) do {:sin, e} end

  def simplify_cos({:num, n}) do {:num, :math.cos(n)} end
  def simplify_cos(e) do {:cos, e} end

  def simplify_ln({{:num, n}}) do {:num, :math.log(n)} end
  def simplify_ln(e) do {:ln, e} end


  def pprint({:num, n}) do "#{n}" end
  def pprint({:var, v}) do "#{v}" end
  def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end

  def pprint({:mul, {:num, n1}, {:num, n2}}) do "#{n1} * #{n2}" end
  def pprint({:mul, {:num, -1}, e}) do "-#{pprint(e)}" end
  def pprint({:mul, {:num, n}, e}) do "#{n}#{pprint(e)}" end
  def pprint({:mul, e1, e2}) do "#{pprint(e1)} * #{pprint(e2)}" end

  def pprint({:exp, e1, e2}) do "(#{pprint(e1)})^(#{pprint(e2)})" end
  #def pprint({:sin, {:num, n}}) do "sin(#{n})" end
  def pprint({:sin, e}) do "sin(#{pprint(e)})" end
  #def pprint({:cos, {:num, n}}) do "cos(#{n})" end
  def pprint({:cos, e}) do "cos(#{pprint(e)})" end
  def pprint({:ln, e}) do "ln(#{pprint(e)})" end
end

#Derivative.test1()
#Derivative.test2()
#Derivative.test3()
#Derivative.test4()
Derivative.test7()
