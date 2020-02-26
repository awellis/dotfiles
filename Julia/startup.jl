# try
#     @eval using Revise
#     # Turn on Revise's automatic-evaluation behavior
#     Revise.async_steal_repl_backend()
# catch err
#     @warn "Could not load Revise."
# end


atreplinit() do repl
    @async try
        sleep(0.1)
        @eval using Revise
        @async Revise.wait_steal_repl_backend()
    catch
        @warn("Could not load Revise.")
    end
end


push!(LOAD_PATH, "$(homedir())/Modules/")

try
    using OhMyREPL
    OhMyREPL.enable_autocomplete_brackets(false)
catch err
    @warn "Could not load OhMyREPL."
end
