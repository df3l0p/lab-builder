# Build

The build provides mecanisms to generate an appropriate vagrant environment.

At the moment of writting, the build provides the following features:

* Usage of multiple Vagrantfile files within the same folder (and thus, reusing the same scripts)
* Substitution of variables within the src/\<project\>/ folder

The build requires a configuration file to run called a `context`. There is no limitations in the number of context created.  
The context needs to be placed under `context/` and must have the following structure:

```ini
[main]
BUILD_PATH = build/<project_name>
VAGRANTFILE = src/<a_project>/<the_vagrant_file>

SUBST-<some_unique_id_among_subst> = <the content to be placed>
SUBST-...
```

`build_path` must be unique amongs context files! Otherwise you might have unexpected results when running vagrant on those build projects

## Substitution

Substitution is performed using `{{<substitution id>}}`  
Example:

```ìni
SUBST-my_subst = my_value
```

needs to be used with `{{my_subst}}` within the `src/` folder.
