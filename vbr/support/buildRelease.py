################################################################################
# python script for building a release package outside of git
#
# run with:
#  python buildRelease.py /path/to/vbr /path/to/release release_type
#
#    /path/to/vbr: the path to the top-level of the vbr repo and
#    /path/to/release: the release folder to create
#    release_type: one of the keys from folder_sets, below, e.g., vbr_core
################################################################################
import sys,os,datetime,shutil

path_to_vbr=sys.argv[1] # absolute path to top level vbr directory
path_to_vbr_release=sys.argv[2] # absolute path to the release folder
release_type=sys.argv[3] # determines folder subsets to copy

print("\nBuilding VBR release")
print("\nTop Level VBR directory: "+path_to_vbr)
print("VBR release directory: "+path_to_vbr_release)
print("release type: "+release_type)

# define release_types (list of folder to be copied recursively)
folder_sets={'vbr_core':[os.path.join('vbr','support'),
                        os.path.join('vbr','4_VBR'),
                        os.path.join('Projects','vbr_core_examples')]}

# read gitignore for list of file types to ignore
ig_fi=os.path.join(path_to_vbr,'.gitignore')
fi_ext_to_ignore=[]
if os.path.isfile(ig_fi):
    with open(ig_fi) as f:
        fi_ext_to_ignore = f.read().splitlines()
    fi_ext_to_ignore="|".join(fi_ext_to_ignore)
    fi_ext_to_ignore=fi_ext_to_ignore.replace('*','')
    fi_ext_to_ignore=fi_ext_to_ignore.split('|')

def ignore_files(path, names):
    # factory function for shutil.copytree
    ignore_list = []
    for file in os.listdir(path):
        (path,fi_ext)=os.path.splitext(file)
        if fi_ext in fi_ext_to_ignore:
            ignore_list.append(file)
    return tuple(ignore_list)

# pull out the release type for this releaes
fo_list=[]
if release_type in folder_sets.keys():
    fo_list=folder_sets[release_type]
else:
    print("release type "+release_type+" is not defined. possible types are:")
    print(folder_sets.keys())

# create the initial directory
keepgoing=True
if os.path.isdir(path_to_vbr_release) is False:
    try:
        os.mkdir(path_to_vbr_release)
    except:
        print("Cannot create release directory, check permissions?")
        keepgoing=False
else:
    print("\nWarning! "+path_to_vbr_release+' already exists!')
    Y_N = raw_input("Continue (will wipe that directory)? (Y/N):")
    if Y_N.lower()!='y':
        keepgoing=False
        print("... quitting without building repo")
    if keepgoing:
        print(" trimming old tree, replanting")
        shutil.rmtree(path_to_vbr_release)
        os.mkdir(path_to_vbr_release)

# copy over folders
if keepgoing:
    print("\ncopying folders...\n")
    for fo in fo_list:
        fo2cp=os.path.join(path_to_vbr,fo)
        fo_dest=os.path.join(path_to_vbr_release,fo)
        print('   copying '+fo2cp+' to '+fo_dest)
        shutil.copytree(fo2cp,fo_dest,ignore=ignore_files)

    print("\ncopying top-level files")
    for fi in os.listdir(path_to_vbr):
        fullfi=os.path.join(path_to_vbr,fi)
        if os.path.isfile(fullfi):
            dest=os.path.join(path_to_vbr_release,fi)
            (path,fi_ext)=os.path.splitext(fullfi)
            if fi_ext not in fi_ext_to_ignore and fi!='.gitignore':
                print("   copying "+fullfi+" to " + dest )
                shutil.copyfile(fullfi,dest)

    now_str=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    fi = open(os.path.join(path_to_vbr_release,'release_notes.txt'), "w")
    fi.write('VBR release built: '+now_str)
    fi.close()
    print("\nRelease Built!")
