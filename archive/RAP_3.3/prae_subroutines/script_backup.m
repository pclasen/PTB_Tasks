function [] = script_backup(callerScript,parentDir,version)
  %
  % [] = jalewpea_script_backup(callerScript,parentDir,version)
  %
  % * callerScript : mfilename() of caller
  % * parentDir    : parent directory of caller
  % * version      : script version of caller
  %
  
  start_dir = pwd;
  
  if ~exist(parentDir,'dir')
    
    error('[*] Parent directory does not exist: %s\n',parentDir);
    
  else
    
    cd(parentDir);
    
    %% Make a backup copy of this script
    
    if exist('./versions','dir');
      
      versionName = sprintf('%s_%s_%s.m',callerScript,version,datestr(now,'yymmdd_HHMM_SS_FFF'));
      
      if ~exist(sprintf('./versions/%s',versionName),'file')
        
        fprintf('\n[+] Backing up %s in %s/versions\n',callerScript,parentDir);
        cmd = sprintf('cp -npv %s.m ./versions/%s',callerScript,versionName);
        [s,r] = system(cmd);
        if ~s; disp(r); end
        
        fprintf('[+] Existing versions of %s:\n',callerScript);
        cmd = sprintf('ls -1 ./versions/%s*',callerScript);
        [s,r] = system(cmd);
        if ~s; disp(r); end
        
      end
      
    else
      
      fprintf('\n[-] ''./versions'' directory not in %s. no backup saved.\n',parentDir);
      
    end
    
    cmd = sprintf('help %s',callerScript);
    eval(cmd);
    
    cd(start_dir);
    
  end
  
end