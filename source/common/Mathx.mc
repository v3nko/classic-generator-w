module Mathx {
    function max(left as Number, right as Number) as Number {
        return left < right ? right : left;
    }    
    
    function min(left as Number, right as Number) as Number {
        return left < right ? left : right;
    }
}
