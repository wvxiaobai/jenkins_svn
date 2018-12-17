<?php
$filePath = isset($argv[1]) ? $argv[1] : '';
$srcPath = isset($argv[2]) ? $argv[2] : '';
echo $srcPath . "\r\n";
if (!$filePath && !$srcPath) {
    die('没有文件');
}

readNLP($filePath, $srcPath);

function readNLP($filePath, $srcPath)
{
    $qian = array(" ", "　", "\t", "\n", "\r");
    try {
        $file = fopen($filePath . '/svn_log.txt', "r"); // 以只读的方式打开文件
        if (empty($file)) {
            $errorCode = 201;
            $errorMessage = "file not found";
            return $errorCode;
        }
        $i = 0;
        //输出文本中所有的行，直到文件结束为止。
        //file_put_contents($filePath.'\svn_cp.sh','#!C:\Program Files\Git\bin\sh.exe');

        //file_put_contents($filePath.'\svn\svn_rm.sh','#!/bin/bash'."\r\n");
        while (!feof($file)) {
            $itemStr = fgets($file); //fgets()函数从文件指针中读取一行
            $arr = explode(' ', $itemStr);
            if (isset($arr[0]) && $arr[0] && isset($arr[7]) && $arr[7]) {

                $arr1 = explode('Trunk', $arr[7]);
                if (isset($arr1[1]) && $arr1[1]) {
                    trim($arr1[1]);
                    $arr1[1] = str_replace($qian, '', $arr1[1]);

                    $tmp = explode('/', $arr1[1]);
                    if (isset($tmp[2]) && $tmp[2] == 'public') {
                        continue;
                    }

                    $dir_tmp = 'svn';
                    $src_tmp = '';
                    $count = count($tmp);
                    foreach ($tmp as $k => $v) {
                        //echo $v."\r\n";
                        if ($k > 1 && $v && stripos($v, '.') === false) {
                            $dir_tmp .= '/' . $v;
                            $src_tmp .= '/' . $v;
                            $mkdir = 'mkdir ' . $dir_tmp;
                            file_put_contents($filePath . '/svn_cp.sh', $mkdir . "\n", FILE_APPEND);
                        }

                        if ($arr[0] != 'D') {
                            if (stripos($v, '.') !== false) {
                                $cp = "cp " . $srcPath . $src_tmp . '/' . $v . ' ' . $dir_tmp . "/" . $v;
                                file_put_contents($filePath . '/svn_cp.sh', $cp . "\n", FILE_APPEND);
                            }
                        } else {
                            if ($k == $count - 1) {
                                if (stripos($v, '.') !== false) {
                                    $rm = "rm -f " . ltrim($src_tmp, '/') . "/" . $v;
                                } else {
                                    $rm = "rm -rf " . ltrim($src_tmp, '/') . "/" . $v;
                                }
                                file_put_contents($filePath . '/svn/svn_rm.sh', $rm . "\n", FILE_APPEND);
                                //@chmod($filePath.'\svn\svn_rm.sh','777');
                            }
                        }
                    }
                    //$tmp[1] = 'svn';
                    //$tmp = implode('/',$tmp);
                }

            }
            ++$i;
        }
        fclose($file);
    } catch (Exception $exception) {
        $errorCode = $exception->getCode();
        $errorMessage = $exception->getMessage();
    }
    return true;
}

?>
