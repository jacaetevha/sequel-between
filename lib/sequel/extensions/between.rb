# frozen-string-literal: true
#
# The +between+ extension adds the ability to perform standard
# BETWEEN comparisons.  For example, with a table like:
#
#   c1 | c2
#   ---+---
#   a  | 1
#   b  | 2
#   c  | 3
#   d  | 4
#
# You can return a result set like:
#
#   c1 | c2
#   ---+---
#   b  | 2
#   c  | 3
#
# First, you need to load the extension into the database:
#
#   DB.extension :between
#
# Then you can use the Sequel.between method to return a Sequel
# expression:
#
#   sb = Sequel.between(:column_name, :lower_bound, :upper_bound)
#
# Additionally, if you want to delay setting either boundary:
#
#   sb = Sequel.between(:column_name, 1).upper(:some_expression)
#   # or:
#   sb = Sequel.between(:column_name).lower(4).upper(Sequel[:col] * Sequel[:col])
#
# These expressions can be used in your datasets, or anywhere else that
# Sequel expressions are allowed:
#
#   DB[:table].where(Sequel.between(:c2).lower(2).upper(3))
#   # or:
#   DB[:table].where(Sequel.between(:c2, 2, 3))
#
# You can negate the expression by sending the +~+ or +negate+ message
# or by including +negated: true+ in the builder message:
#   DB[:table].where(Sequel.between(:c2, 2, 3).~)
#   # or:
#   DB[:table].where(Sequel.between(:c2, 2, 3).negate)
#   # or:
#   DB[:table].where(Sequel.between(:c2, 2, 3, negated: true)
#
# This extension currenly supports any database that supports the BETWEEN/AND clause:
#
# Related module: Sequel::SQL::BetweenExpression
#
module Sequel
  module SQL
    # Represents an SQL expression using the BETWEEN clause.
    class BetweenExpression < BooleanExpression

      # These methods are added to expressions, allowing them to return BETWEEN
      # AND expressions based on the receiving expression.
      module Methods
        # Return a BetweenExpression, using the BETWEEN clause, with the receiver
        # as the test expression and the arguments as the bounds. Optionally,
        # include the +negated: <true|false>+ keyword argument to return a NOT
        # BETWEEN expression.
        def between(lower, upper, negated: false)
          BetweenExpression.new(self, lower, upper, negated: negated)
        end

        # Return a negated BetweenExpression, using the BETWEEN clause, with the
        # receiver as the test expression and the arguments as the bounds.
        def not_between(lower, upper)
          BetweenExpression.new(self, lower, upper, negated: true)
        end
      end

      # These methods are added to datasets using the +between+ extension,
      # for the purposes of correctly literalizing BetweenExpression
      # expressions.
      module DatasetMethods
        # Append the SQL fragment for the BETWEEN or NOT BETWEEN expression
        # to the SQL query.
        def between_sql_append(sql, between_expr)
          sql << '('
          literal_append(sql, between_expr.expression)
          sql << ' NOT' if between_expr.negated?
          sql << ' BETWEEN '
          literal_append(sql, between_expr.lower_bound)
          sql << ' AND '
          literal_append(sql, between_expr.upper_bound)
          sql << ')'
        end
      end

      attr_reader :expression, :lower_bound, :upper_bound

      def initialize(expr, lower, upper, negated: false)
        @expression  = expr
        @lower_bound = lower
        @upper_bound = upper
        @negated     = negated
        freeze
      end

      def expr(val)
        return self if val == expression

        self.class.new(val, lower, upper)
      end

      def lower(val)
        return self if val == lower

        self.class.new(expr, val, upper)
      end

      def negate
        if negated
          self.class.new(val, lower, upper, negated: false)
        else
          self.class.new(val, lower, upper, negated: true)
        end
      end
      alias ~ negate

      def negated?
        @negated
      end

      def upper(val)
        return self if val == upper

        self.class.new(expr, lower, val)
      end

      to_s_method :between_sql
    end

    module Builders
      def between(*args, negated: false)
        expr, lower, upper = args
        case expr
        when ::Sequel::SQL::BetweenExpression
          expr.lower(lower || expr.lower_bound).upper(upper || expr.upper_bound).yield_self do |it|
            negated ? it.negate : it
          end
        else
          ::Sequel::SQL::BetweenExpression.new(expr, lower, upper, negated: negated)
        end
      end

      def not_between(*args)
        between(*args, negated: true)
      end
    end
  end

  class SQL::GenericExpression
    include SQL::BetweenExpression::Methods
  end

  class LiteralString
    include SQL::BetweenExpression::Methods
  end

  Dataset.register_extension(:between, SQL::BetweenExpression::DatasetMethods)
end

# :nocov:
if Sequel.core_extensions?
  class Symbol
    include Sequel::SQL::BetweenExpression::Methods
  end
end

if defined?(Sequel::CoreRefinements)
  module Sequel::CoreRefinements
    refine Symbol do
      send INCLUDE_METH, Sequel::SQL::BetweenExpression::Methods
    end
  end
end
# :nocov:
