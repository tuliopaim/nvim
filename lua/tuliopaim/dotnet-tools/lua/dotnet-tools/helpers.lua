local M = {}

M.get_function_name_with_treesitter = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1
    local col = cursor[2]
    local parser = vim.treesitter.get_parser(0, 'c_sharp')
    if not parser then return end

    local tree = parser:parse()[1]
    local root = tree:root()

    -- Traverse up the tree from the current node until we find a method declaration
    local node = root:named_descendant_for_range(line, col, line, col)
    while node do
        if node:type() == 'method_declaration' then
            -- Get the name node
            local name_node = node:field('name')[1]

            if name_node then
                local function_name = vim.treesitter.get_node_text(name_node, 0)
                return function_name
            end
        end
        node = node:parent()
    end
end

M.get_class_name = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1
    local col = cursor[2]
    local parser = vim.treesitter.get_parser()
    if not parser then return end
    local lang_tree = parser:language_for_range { line, col, line, col }
    for _, tree in ipairs(lang_tree:trees()) do
        local root = tree:root()
        -- Traverse up the tree from the current node until we find a class declaration
        local node = root:named_descendant_for_range(line, col, line, col)
        while node do
            if node:type() == 'class_declaration' then -- Adjust the type according to Treesitter's C# queries
                -- Assuming the class name is a direct child of the class declaration, which might need adjustments
                for child_node in node:iter_children() do
                    if child_node:type() == "identifier" then -- The type for the node containing the class name might need adjustments
                        local class_name = vim.treesitter.get_node_text(child_node, 0)
                        print("Class name: " .. class_name)
                        return class_name
                    end
                end
            end
            node = node:parent()
        end
    end
end

return M
