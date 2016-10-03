function ret_none()
end

function ret_1()
    return 1
end

function ret_1_2()
    return 1, 2
end

function sum(a,b)
    return (a or 0) + (b or 0)
end

function ret_array()
    return {1, 2, 3}
end

function ret_table()
    return {1, 2, 3, str = "value", 4, 5, bool = true}
end

return "test"