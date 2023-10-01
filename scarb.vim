" Author: swan_of_bodom <swan_of_bodom@hotmail.com>,
" Description: scarb for cairo files

call ale#Set('cairo_scarb_check_all_targets', 0)
call ale#Set('cairo_scarb_check_examples', 0)
call ale#Set('cairo_scarb_check_tests', 0)
call ale#Set('cairo_scarb_avoid_whole_workspace', 1)
call ale#Set('cairo_scarb_default_feature_behavior', 'default')
call ale#Set('cairo_scarb_include_features', '')
call ale#Set('cairo_scarb_target_dir', '')

function! ale_linters#cairo#scarb#GetSierraExecutable(bufnr) abort
    if ale#path#FindNearestFile(a:bufnr, 'Scarb.toml') isnot# ''
        return 'scarb'
    else
        " if there is no Scarb.toml file, we don't use scarb even if it exists,
        " so we return '', because executable('') apparently always fails
        return ''
    endif
endfunction

function! ale_linters#cairo#scarb#GetCwd(buffer) abort
    if ale#Var(a:buffer, 'cairo_scarb_avoid_whole_workspace')
        let l:nearest_scarb = ale#path#FindNearestFile(a:buffer, 'Scarb.toml')
        let l:nearest_scarb_dir = fnamemodify(l:nearest_scarb, ':h')

        if l:nearest_scarb_dir isnot# '.'
            return l:nearest_scarb_dir
        endif
    endif

    return ''
endfunction

function! ale_linters#cairo#scarb#GetCommand(buffer, version) abort
    let l:use_all_targets = ale#Var(a:buffer, 'cairo_scarb_check_all_targets')
    \   && ale#semver#GTE(a:version, [0, 22, 0])
    let l:use_examples = ale#Var(a:buffer, 'cairo_scarb_check_examples')
    \   && ale#semver#GTE(a:version, [0, 22, 0])
    let l:use_tests = ale#Var(a:buffer, 'cairo_scarb_check_tests')
    \   && ale#semver#GTE(a:version, [0, 22, 0])
    let l:target_dir = ale#Var(a:buffer, 'cairo_scarb_target_dir')
    let l:use_target_dir = !empty(l:target_dir)
    \   && ale#semver#GTE(a:version, [0, 17, 0])

    let l:include_features = ale#Var(a:buffer, 'cairo_scarb_include_features')

    if !empty(l:include_features)
        let l:include_features = ' --features ' . ale#Escape(l:include_features)
    endif

    let l:default_feature_behavior = ale#Var(a:buffer, 'cairo_scarb_default_feature_behavior')

    if l:default_feature_behavior is# 'all'
        let l:include_features = ''
        let l:default_feature = ' --all-features'
    elseif l:default_feature_behavior is# 'none'
        let l:default_feature = ' --no-default-features'
    else
        let l:default_feature = ''
    endif

    let l:subcommand = 'build'

    return 'scarb '
    \   . l:subcommand
    \   . (l:use_all_targets ? ' --all-targets' : '')
    \   . (l:use_examples ? ' --examples' : '')
    \   . (l:use_tests ? ' --tests' : '')
    \   . (l:use_target_dir ? (' --target-dir ' . ale#Escape(l:target_dir)) : '')
    \   . l:default_feature
    \   . l:include_features
endfunction

call ale#linter#Define('cairo', {
\   'name': 'scarb',
\   'executable': function('ale_linters#cairo#scarb#GetSierraExecutable'),
\   'cwd': function('ale_linters#cairo#scarb#GetCwd'),
\   'command': {buffer -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale_linters#cairo#scarb#GetSierraExecutable(buffer),
\       '%e --version',
\       function('ale_linters#cairo#scarb#GetCommand'),
\   )},
\   'callback': 'ale#handlers#cairo#HandleCairoErrors',
\   'output_stream': 'both',
\   'lint_file': 1,
\})
