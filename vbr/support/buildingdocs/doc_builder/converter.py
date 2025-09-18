import os
from shutil import copyfile


_possible_vbr_path_envs = ['VBRpath', 'vbrdir']


class VBRinit(object):
    ''' VBRinit class '''
    def __init__(self,**kwargs):
        self.VBRpath = None
        for pth in _possible_vbr_path_envs:
            if self.VBRpath is None:
                self.VBRpath=os.environ.get(pth, None)

        if kwargs is not None:
            for key in kwargs.keys():
                setattr(self,key,kwargs[key])

        if self.VBRpath is not None:
            self.DocsPath=os.path.join(self.VBRpath,'docs')
            self.CorePath=os.path.join(self.VBRpath,'vbr','vbrCore')
            self.ProjectPath=os.path.join(self.VBRpath,'Projects')

        extramsg={'VBRpath': (" Either pass VBRpath='/path/to/vbr'"
            " or set VBRpath environment variable")}
        for req in ['VBRpath']:
            if getattr(self,req) is None:
                msg='converter.VBRinit: '+req+' is not set but required.'
                if req in extramsg.keys():
                    msg=msg+extramsg[req]
                raise ValueError(msg)

    def header(self,permalinkpath:str,title:str='', include_toc: bool = False):
        lines: list[str]=[]
        lines.append('---\n')
        lines.append('permalink: '+permalinkpath+'\n')
        lines.append('title: "'+title+'"\n')
        if include_toc:
            lines.append("toc: true\n")
        lines.append('---\n\n')
        return lines


class CBexample(VBRinit):
    ''' vbr_core_examples single file parser '''
    def __init__(self,mfile=None,**kwargs):
        VBRinit.__init__(self,**kwargs)

        # set up the relevant paths
        self.mfile_dir=os.path.join(self.ProjectPath,'vbr_core_examples')

        if mfile is not None:
            self.mfile=mfile.split('.')[0]
            self.mfile_fullpath=os.path.join(self.mfile_dir,mfile)
            self.permalinkpath='/examples/'+self.mfile+'/'
            self.checkForImages()

        self.examplePath=os.path.join(self.DocsPath,'_pages','examples')
        if mfile is not None:
            self.md_fullpath=os.path.join(self.examplePath,self.mfile+'.md')

        # build the markdown file
        if mfile is not None:
            self.md_rows=self.build_md()


        return

    def build_md(self):
        ''' builds the markdown text '''
        rows=self.header(self.permalinkpath)
        rows.append('# '+self.mfile + '.m\n')
        # add the figures if there
        if self.HasImageFiles:
            rows.append('## output figures\n')
            for f in self.ImFiles:
                ImLink='/vbr/assets/images/CBs/'+f
                ImName=f.split('.')[0]
                rows.append("\n!['"+ImName+"']("+ImLink+'){:class="img-responsive"}\n')


        # parse the mfile into matlab code block
        mfile_text=None
        with open (self.mfile_fullpath, "r") as mfile:
            mfile_text=mfile.readlines()

        if mfile_text is not None:
            rows.append('## contents\n')
            rows.append("```matlab\n")
            for ln in mfile_text:
                rows.append(ln)
            rows.append("\n```\n")

        return rows

    def write_md(self):

        if os.path.isfile(self.md_fullpath):
            print("    removing existing...")
            os.remove(self.md_fullpath)

        print("    writing markdown to "+self.md_fullpath)
        with open (self.md_fullpath, "w") as mdfile:
            for ln in self.md_rows:
                mdfile.write(ln)
        return

    def checkForImages(self):

        self.HasImageFiles=False
        self.ImDir=os.path.join(self.mfile_dir,'figures')

        self.ImFiles = [f for f in os.listdir(self.ImDir)
                if os.path.isfile(os.path.join(self.ImDir, f)) and self.mfile in f]

        if len(self.ImFiles)>0:
           self.HasImageFiles=True

        self.ImTargDir=os.path.join(self.DocsPath,'assets','images','CBs')
        return

    def copyImages(self):

        if self.HasImageFiles:
            for ImFi in self.ImFiles:
                Targ=os.path.join(self.ImTargDir,ImFi)
                TargFi=os.path.join(self.ImTargDir,ImFi)
                FullFi=os.path.join(self.ImDir,ImFi)
                print("    copying "+ImFi +" to "+self.ImTargDir)
                copyfile(FullFi,TargFi)

        return


class CBwalker(object):
    def __init__(self,**kwargs):
        self.CB0=CBexample() # pulls in default paths
        return

    def clearTargetDir(self):
        print("clearing out target "+self.CB0.examplePath+" of CB's")

        fis2rm = [f for f in os.listdir(self.CB0.examplePath)
                        if os.path.isfile(os.path.join(self.CB0.examplePath,f))]

        for f in fis2rm:
            if 'CB_' in f or f=='vbrcore.md':
                print("  removing "+f)
                fullfi=os.path.join(self.CB0.examplePath,f)
                os.remove(fullfi)
        return

    def walkDir(self,clearTargetDir=True):
        ''' walks the mfile directory, builds markdown file for each mfile '''

        if clearTargetDir:
            self.clearTargetDir()

        mFiles = [f for f in os.listdir(self.CB0.mfile_dir)
                        if os.path.isfile(os.path.join(self.CB0.mfile_dir, f))]

        mFiles.sort()
        CB_list=[]
        for f in mFiles:
            if '.m' in f and 'CB_' in f:
                print("Processing "+f)
                CB=CBexample(mfile=f)
                CB.write_md()
                CB.copyImages()
                CB_list.append(self.CBlistEntry(f,CB.permalinkpath))


        # rebuild vbrcore.md:
        vbrcore=self.header()
        for ln in CB_list:
            vbrcore.append(ln)

        print("Rebuilding vbrcore.md")
        with open(os.path.join(CB.examplePath,'vbrcore.md'),'w') as vbrCorefi:
            for ln in vbrcore:
                vbrCorefi.write(ln)

        return

    def CBlistEntry(self,f,permalink):
        thestr='* `'+f+'` [link](/vbr'+permalink+')\n'
        return thestr

    def header(self):
        rows=[]
        rows.append('---\n')
        rows.append('permalink: /examples/vbrcore/\n')
        rows.append('title: ""\n')
        rows.append('toc: false\n')
        rows.append('---\n\n')

        Details=('Simple "Cookbook" (CB) scripts demonstrating various use cases '
        'of the VBR Calculator are available in `vbr/Projects/vbr_core_examples/`'
        ' and available to view here:\n')
        rows.append(Details)
        return rows


def sync_release_notes():

    vbrinfo = VBRinit()

    target = os.path.join(vbrinfo.DocsPath, '_pages', 'history.md')

    rows = []
    rows.append('---\n')
    rows.append('permalink: /history/\n')
    rows.append('title: "Release Notes"\n')
    rows.append('toc: false\n')
    rows.append('---\n\n')

    r_notes = os.path.join(str(vbrinfo.VBRpath), 'release_notes.md')
    r_history = os.path.join(str(vbrinfo.VBRpath), 'release_history.md')

    with open(r_notes, 'r') as f:
        rows += f.readlines()

    rows.append('\n\n')

    with open(r_history, 'r') as f:
        rows += f.readlines()

    rows.append('\n\n')
    with open(target, 'w') as f:
        f.writelines(rows)



class MatlabFunction:
    def __init__(self,
                 mfile_name: str,
                 possible_paths: list[os.PathLike] | list[str],
                 docstring_wrapping_symbol: str = '%%%%%'):
        self.mfile_name = mfile_name
        self.func_name = mfile_name.replace(".m","")

        parent_dir: None | str = None
        full_file: None |  str = None
        for path in possible_paths:
            maybe_file =  os.path.abspath(os.path.join(path, self.mfile_name))
            if os.path.isfile(maybe_file):
                full_file = str(maybe_file)
                parent_dir = str(path)

        if parent_dir is None:
            raise FileNotFoundError(f"could not find {mfile_name} in {possible_paths}")

        self.parent_dir = str(parent_dir)
        self.full_file = str(full_file)
        self.docstring_wrapping_symbol = docstring_wrapping_symbol
        vbr_rel_top = os.path.join('vbr','vbr')
        self.rel_path = vbr_rel_top + self.full_file.split(vbr_rel_top)[1]


    _raw_lines: None | list[str] = None

    @property
    def raw_lines(self):
        if self._raw_lines is None:
            with open(self.full_file, 'r') as fi:
                raw_lines = fi.readlines()
            self._raw_lines = [rl.strip() for rl in raw_lines]
        return self._raw_lines

    _docstring: None | list[str] = None

    @property
    def docstring(self):
        if self._docstring is None:
            lines = self.raw_lines

            docstring_lines: list[str] = ["'''\n"]

            i_line = 0;
            n_lines = len(lines)
            in_docstring = False
            docstring_signals = 0

            while i_line < n_lines:
                if lines[i_line].strip().startswith(self.docstring_wrapping_symbol):
                    in_docstring = True
                    docstring_signals += 1

                if in_docstring:
                    docstring_lines.append("    "+lines[i_line]+"\n")

                if docstring_signals == 2:
                    i_line = n_lines * 2

                i_line += 1

            docstring_lines.append("'''\n")

            self._docstring = docstring_lines
        return self._docstring


def list_mfiles(directory: str | os.PathLike):
    fnames: list[str] = []
    for fi in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, fi)) and fi.endswith('m'):
            fnames.append(str(fi))
    return fnames



class SupportFunctions(VBRinit):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.target_md = os.path.join(self.DocsPath, '_pages', 'vbrmethods', 'support', 'support.md')

        # assemble some function names
        dens_path = os.path.join(self.CorePath, 'functions', 'density')
        dens_funcs = list_mfiles(dens_path)

        io_path = os.path.join(self.CorePath, 'functions', 'io_functions')
        io_funcs = list_mfiles(io_path)

        thermo_path = os.path.join(self.CorePath, 'functions', 'thermal_properties')
        thermo_prop_funcs = list_mfiles(thermo_path)
        thermo_prop_funcs.append('sr_water_fugacity.m')
        thermo_prop_funcs.append('Qinv_from_J1_J2.m')

        support_path = os.path.join(str(self.VBRpath), 'vbr', 'support')
        gen_func_path = os.path.join(str(self.CorePath), 'functions')
        support_funcs = ['vbr_version.m', 'VBR_list_methods.m', 'full_nd.m',
                         'vbr_categorical_color.m', 'vbr_categorical_cmap_array.m']
        support_funcs = support_funcs + io_funcs

        gen_funcs =['checkStructForField.m', 'get_nested_field_from_struct.m',
                    'nested_structure_update.m',
                    'is_octave.m', 'varargin_keyvals_to_structure.m', ]

        self.support_functions = {
            'density': dens_funcs,
            'other_properties': thermo_prop_funcs,
            'VBRc_support_functions': support_funcs,
            'developer_functions': gen_funcs,
        }

        self.paths = {
            'density': [dens_path,],
            'other_properties': [thermo_path, os.path.join(str(self.CorePath), 'functions')],
            'VBRc_support_functions': [io_path, support_path, gen_func_path],
            'developer_functions': [support_path,],
        }

        self.categories = {
            'density': 'functions related to calculating density',
            'other_properties': 'functions related to other thermodynamic properties',
            'VBRc_support_functions': 'useful functions for the VBRc user',
            'developer_functions': 'functions that you may find useful for developing code'
        }

        self.titles = {
            'density': 'Density',
            'other_properties': 'Other thermodynamic properties',
            'VBRc_support_functions': 'VBRc support',
            'developer_functions': 'Developer Support'
        }

        self.func_readers: dict[str, list[MatlabFunction]] =  {}
        for cat in self.titles.keys():
            self.func_readers[cat] = []
            for func in self.support_functions[cat]:
                self.func_readers[cat].append(MatlabFunction(func, self.paths[cat]))

    def build_lines(self):

        lines = self.header('/vbrmethods/support/support/', 'Additional functions', include_toc=True)

        lines.append("# Additional Functions\n")
        lines.append("This is a list of functions that you may find useful when using ")
        lines.append("or developing the VBRc. Note to developers: this page is auto-generated ")
        lines.append("from `vbr/vbr/support/buildingdocs/sync_support_functions.py`. \n")

        for cat,title in self.titles.items():
            lines.append(f"\n## {title}\n")
            lines.append(self.categories[cat]+"\n")

            # list the functions, with links to later
            funcs = self.func_readers[cat]
            for func in funcs:
                lines.append(f"* [{func.func_name}]({func.func_name})\n")

        lines.append("\n## Full Docstrings\n")

        for cat, title in self.titles.items():
            cat_title = f"{title}: docstrings"
            cat_title_link = cat_title.lower().replace(" ",'-')
            lines.append(f"\n### {cat_title}\n")
            # list the functions
            funcs = self.func_readers[cat]
            for func in funcs:
                lines.append(f"\n#### {func.func_name}\n")
                lines.append(f"path: `{func.rel_path}`\n\n")
                lines += func.docstring
                lines.append(f"[top of category!]({cat_title_link})\n")
                lines.append("[top of page!](additional-functions)\n")



        return lines


    def write_page(self):
        lines = self.build_lines()

        with open(self.target_md, 'w') as fi:
            fi.writelines(lines)


def sync_support_functions():
    support_funcs = SupportFunctions()
    support_funcs.write_page()
