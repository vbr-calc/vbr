import os
from shutil import copyfile

class VBRinit(object):
    ''' VBRinit class '''
    def __init__(self,**kwargs):

        self.VBRpath=os.environ.get('VBRpath',None)

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

    def header(self,permalinkpath,title=''):
        lines=[]
        lines.append('---\n')
        lines.append('permalink: '+permalinkpath+'\n')
        lines.append('title: "'+title+'"\n')
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
            rows.append('```matlab\n')
            for ln in mfile_text:
                rows.append(ln)
            rows.append('```\n')

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
