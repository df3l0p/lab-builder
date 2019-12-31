from invoke import task
import os
import tasks.core.utils as myutils

           
@task(help={'vagrant_context_path': "Path to the context file"})
def checksubst(ctx, vagrant_context_path):
    """
    Return a list of substitution placehoder that
    have not been treated
    """
    context = myutils.context_from_config(vagrant_context_path)

    try:
        ctx.run('ag -h', echo=False, hide='out')
        command = ('ag -oir --nopager --vimgrep --ignore "*.html" '
                    '--ignore "*.js" --ignore-dir "app_templates" '
                    '--ignore-dir "appserver" "\{\{[a-zA-Z_0-9]{3,}\}\}"  %s')
    except Exception:
        command = ('grep -oir -E "\{\{[a-zA-Z_0-9]{3,}\}\}" --exclude="*.html" '
                    '--exclude="*.js" --exclude="*.o"  %s')

    for service, params in services.items():
        build_path = params['build_path']
        build_path = os.path.join(os.getcwd(), build_path)
        result = ctx.run(
            command % build_path,
            echo=False,
            warn=True,
            hide='out',
        )
        for entry in result.stdout.split('\n'):
            if entry: 
                if not entry.startswith('Binary file'):
                    path_subst_values = entry.split(':')
                    print("warning: found %s in %s" % (
                        path_subst_values[1],
                        path_subst_values[0]
                        ))

@task(help={'vagrant_context_path': 'Path to context path'})
def vagrant_context(ctx, vagrant_context_path):
    """
    Build vagrant environment with with a vagrant context configuration
    file. 
    The build will rsync the files from the 'vagrentfile' parent 
    directory in the 'build_path' folder. After that, any {{%s}} variable 
    is substitute with the relevant value from the configuration file.
    :param ctx: context (invoke)
    :param vagrant_context_path: vagrant context filepath
    :type vagrant_context_path: string
    """
    context = myutils.context_from_config(vagrant_context_path)

    main_context = context["main"]
    os.makedirs(main_context["build_path"], exist_ok=True)
    
    # Copy the folder of the vagrantfile into the build_path
    source_dir = os.path.join(
        os.path.dirname(main_context["vagrantfile"]), 
        "*"
    )
    ctx.run('rsync -rvla --delete --exclude Vagrantfile* {} {}'.format(
        source_dir,
        main_context["build_path"]
    ))

    # copy the vagrantfile into the build_path
    ctx.run('cp {} {}'.format(
        main_context["vagrantfile"],
        os.path.join(
            main_context["build_path"],
            "Vagrantfile"
        )
    ))

    myutils.substitute(ctx, main_context)
