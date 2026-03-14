/*
 * Copyright (C) 2025 Mobile Porting Team
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package mobile.backend;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * A storage class for mobile with enhanced error handling and logging.
 * @author Karim Akra and Homura Akemi (HomuHomu833)
 * Enhanced by AI Assistant
 */
class StorageUtil
{
	#if sys
	// Hata mesajları için log sistemi
	private static var errorLog:Array<String> = [];
	private static var debugMode:Bool = true; // Detaylı log için
	
	/**
	 * Ana depolama dizinini döndürür
	 */
	public static function getStorageDirectory():String
	{
		var path:String = #if android haxe.io.Path.addTrailingSlash(AndroidContext.getExternalFilesDir()) 
						  #elseif ios lime.system.System.documentsDirectory 
						  #else Sys.getCwd() #end;
		
		if (debugMode)
			trace('[StorageUtil] Storage Directory: $path');
		
		return path;
	}

	/**
	 * Dosya kaydetme - Geliştirilmiş hata yönetimi ile
	 */
	public static function saveContent(fileName:String, fileData:String, ?alert:Bool = true):Bool
	{
		if (fileName == null || fileName.length == 0)
		{
			logError('saveContent', 'Dosya adı boş olamaz!');
			if (alert)
				showError('Geçersiz dosya adı!');
			return false;
		}

		if (fileData == null)
		{
			logError('saveContent', 'Dosya verisi null olamaz!');
			if (alert)
				showError('Kaydedilecek veri bulunamadı!');
			return false;
		}

		final folder:String = #if android getExternalStorageDirectory() #else Sys.getCwd() #end + 'saves/';
		
		try
		{
			// Dizin kontrolü ve oluşturma
			if (!createDirectoryIfNotExists(folder))
			{
				logError('saveContent', 'Dizin oluşturulamadı: $folder');
				if (alert)
					showError(Language.getPhrase('folder_create_fail', 'Kayıt klasörü oluşturulamadı!'));
				return false;
			}

			// Dosya yolu kontrolü
			var fullPath:String = folder + fileName;
			if (debugMode)
				trace('[StorageUtil] Saving to: $fullPath');

			// Eğer dosya varsa yedek al
			if (FileSystem.exists(fullPath))
			{
				try
				{
					backupFile(fullPath);
				}
				catch (e:Dynamic)
				{
					logError('saveContent', 'Yedek oluşturulamadı: ${e.message}');
					// Yedek hatası kritik değil, devam et
				}
			}

			// Dosyayı kaydet
			File.saveContent(fullPath, fileData);
			
			// Dosyanın gerçekten kaydedildiğini doğrula
			if (!FileSystem.exists(fullPath))
			{
				logError('saveContent', 'Dosya kaydedildi ama doğrulanamadı!');
				if (alert)
					showError('Dosya kaydetme doğrulaması başarısız!');
				return false;
			}

			// Dosya boyutu kontrolü
			var fileSize:Int = FileSystem.stat(fullPath).size;
			if (fileSize == 0)
			{
				logError('saveContent', 'Kaydedilen dosya boş!');
				if (alert)
					showError('Dosya boş kaydedildi!');
				return false;
			}

			if (debugMode)
				trace('[StorageUtil] File saved successfully: $fileName ($fileSize bytes)');

			if (alert)
				showSuccess(Language.getPhrase('file_save_success', '{1} başarıyla kaydedildi.', [fileName]));
			
			return true;
		}
		catch (e:Dynamic)
		{
			var errorMsg:String = 'Dosya kaydetme hatası: ${e.message}';
			logError('saveContent', errorMsg);
			
			if (alert)
				showError(Language.getPhrase('file_save_fail', '{1} kaydetme başarısız.\n({2})', [fileName, e.message]));
			else
				trace('[StorageUtil ERROR] $fileName kaydedilemedi. (${e.message})');
			
			return false;
		}
	}

	/**
	 * Dosya okuma - YENİ
	 */
	public static function loadContent(fileName:String, ?alert:Bool = true):String
	{
		if (fileName == null || fileName.length == 0)
		{
			logError('loadContent', 'Dosya adı boş olamaz!');
			if (alert)
				showError('Geçersiz dosya adı!');
			return null;
		}

		final folder:String = #if android getExternalStorageDirectory() #else Sys.getCwd() #end + 'saves/';
		var fullPath:String = folder + fileName;

		try
		{
			if (!FileSystem.exists(fullPath))
			{
				logError('loadContent', 'Dosya bulunamadı: $fullPath');
				if (alert)
					showError(Language.getPhrase('file_not_found', '{1} bulunamadı!', [fileName]));
				return null;
			}

			if (FileSystem.stat(fullPath).size == 0)
			{
				logError('loadContent', 'Dosya boş: $fullPath');
				if (alert)
					showError(Language.getPhrase('file_empty', '{1} dosyası boş!', [fileName]));
				return null;
			}

			var content:String = File.getContent(fullPath);
			
			if (debugMode)
				trace('[StorageUtil] File loaded: $fileName (${content.length} chars)');

			return content;
		}
		catch (e:Dynamic)
		{
			var errorMsg:String = 'Dosya okuma hatası: ${e.message}';
			logError('loadContent', errorMsg);
			
			if (alert)
				showError(Language.getPhrase('file_load_fail', '{1} okunamadı.\n({2})', [fileName, e.message]));
			
			return null;
		}
	}

	/**
	 * Dosya var mı kontrolü - YENİ
	 */
	public static function fileExists(fileName:String, ?inSavesFolder:Bool = true):Bool
	{
		try
		{
			var fullPath:String = inSavesFolder ? 
				(#if android getExternalStorageDirectory() #else Sys.getCwd() #end + 'saves/' + fileName) : 
				fileName;
			
			return FileSystem.exists(fullPath);
		}
		catch (e:Dynamic)
		{
			logError('fileExists', 'Dosya kontrol hatası: ${e.message}');
			return false;
		}
	}

	/**
	 * Dosya silme - YENİ
	 */
	public static function deleteFile(fileName:String, ?alert:Bool = true):Bool
	{
		if (fileName == null || fileName.length == 0)
		{
			logError('deleteFile', 'Dosya adı boş olamaz!');
			return false;
		}

		final folder:String = #if android getExternalStorageDirectory() #else Sys.getCwd() #end + 'saves/';
		var fullPath:String = folder + fileName;

		try
		{
			if (!FileSystem.exists(fullPath))
			{
				logError('deleteFile', 'Silinecek dosya bulunamadı: $fullPath');
				if (alert)
					showError(Language.getPhrase('file_not_found', '{1} bulunamadı!', [fileName]));
				return false;
			}

			// Silmeden önce yedek al
			try
			{
				backupFile(fullPath);
			}
			catch (e:Dynamic)
			{
				logError('deleteFile', 'Yedek oluşturulamadı: ${e.message}');
			}

			FileSystem.deleteFile(fullPath);

			if (FileSystem.exists(fullPath))
			{
				logError('deleteFile', 'Dosya silinemedi!');
				if (alert)
					showError('Dosya silme başarısız!');
				return false;
			}

			if (debugMode)
				trace('[StorageUtil] File deleted: $fileName');

			if (alert)
				showSuccess(Language.getPhrase('file_delete_success', '{1} silindi.', [fileName]));

			return true;
		}
		catch (e:Dynamic)
		{
			logError('deleteFile', 'Dosya silme hatası: ${e.message}');
			if (alert)
				showError(Language.getPhrase('file_delete_fail', '{1} silinemedi.\n({2})', [fileName, e.message]));
			return false;
		}
	}

	/**
	 * Dosya kopyalama - YENİ
	 */
	public static function copyFile(source:String, destination:String, ?alert:Bool = true):Bool
	{
		try
		{
			if (!FileSystem.exists(source))
			{
				logError('copyFile', 'Kaynak dosya bulunamadı: $source');
				if (alert)
					showError('Kaynak dosya bulunamadı!');
				return false;
			}

			var content:String = File.getContent(source);
			File.saveContent(destination, content);

			if (!FileSystem.exists(destination))
			{
				logError('copyFile', 'Dosya kopyalanamadı!');
				return false;
			}

			if (debugMode)
				trace('[StorageUtil] File copied: $source -> $destination');

			return true;
		}
		catch (e:Dynamic)
		{
			logError('copyFile', 'Dosya kopyalama hatası: ${e.message}');
			if (alert)
				showError('Dosya kopyalanamadı!\n${e.message}');
			return false;
		}
	}

	/**
	 * Dizin oluşturma (yoksa) - YENİ
	 */
	public static function createDirectoryIfNotExists(path:String):Bool
	{
		try
		{
			if (!FileSystem.exists(path))
			{
				if (debugMode)
					trace('[StorageUtil] Creating directory: $path');
				
				FileSystem.createDirectory(path);
				
				if (!FileSystem.exists(path))
				{
					logError('createDirectory', 'Dizin oluşturulamadı: $path');
					return false;
				}
			}
			return true;
		}
		catch (e:Dynamic)
		{
			logError('createDirectory', 'Dizin oluşturma hatası: ${e.message}');
			return false;
		}
	}

	/**
	 * Dosya yedeği oluşturma - YENİ
	 */
	private static function backupFile(filePath:String):Void
	{
		if (!FileSystem.exists(filePath))
			return;

		var backupPath:String = filePath + '.backup';
		var content:String = File.getContent(filePath);
		File.saveContent(backupPath, content);

		if (debugMode)
			trace('[StorageUtil] Backup created: $backupPath');
	}

	/**
	 * Hata loglama - YENİ
	 */
	private static function logError(functionName:String, message:String):Void
	{
		var timestamp:String = Date.now().toString();
		var logMessage:String = '[$timestamp] [$functionName] $message';
		
		errorLog.push(logMessage);
		trace('[StorageUtil ERROR] $logMessage');

		// Error log dosyasına kaydet
		try
		{
			var logPath:String = getStorageDirectory() + 'storage_errors.log';
			var existingLog:String = FileSystem.exists(logPath) ? File.getContent(logPath) : '';
			File.saveContent(logPath, existingLog + logMessage + '\n');
		}
		catch (e:Dynamic)
		{
			trace('[StorageUtil] Log dosyası yazılamadı: ${e.message}');
		}
	}

	/**
	 * Hata popup gösterme - YENİ
	 */
	private static function showError(message:String):Void
	{
		CoolUtil.showPopUp(message, Language.getPhrase('mobile_error', "HATA!"));
	}

	/**
	 * Başarı popup gösterme - YENİ
	 */
	private static function showSuccess(message:String):Void
	{
		CoolUtil.showPopUp(message, Language.getPhrase('mobile_success', "Başarılı!"));
	}

	/**
	 * Hata loglarını al - YENİ
	 */
	public static function getErrorLogs():Array<String>
	{
		return errorLog.copy();
	}

	/**
	 * Hata loglarını temizle - YENİ
	 */
	public static function clearErrorLogs():Void
	{
		errorLog = [];
		
		try
		{
			var logPath:String = getStorageDirectory() + 'storage_errors.log';
			if (FileSystem.exists(logPath))
				FileSystem.deleteFile(logPath);
		}
		catch (e:Dynamic)
		{
			trace('[StorageUtil] Log dosyası silinemedi: ${e.message}');
		}
	}

	/**
	 * Debug mode açma/kapama - YENİ
	 */
	public static function setDebugMode(enabled:Bool):Void
	{
		debugMode = enabled;
		trace('[StorageUtil] Debug mode: ${enabled ? "AÇIK" : "KAPALI"}');
	}

	#if android
	// always force path due to haxe
	public static function getExternalStorageDirectory():String
		return '/sdcard/.PsychEngine/';

	/**
	 * İzin kontrolü - YENİ
	 */
	public static function checkPermissions():Bool
	{
		try
		{
			var hasPermissions:Bool = false;

			if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
			{
				hasPermissions = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES')
					|| AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_VIDEO')
					|| AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_AUDIO');
			}
			else
			{
				hasPermissions = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE');
			}

			if (debugMode)
				trace('[StorageUtil] Permissions check: ${hasPermissions ? "OK" : "FAIL"}');

			return hasPermissions;
		}
		catch (e:Dynamic)
		{
			logError('checkPermissions', 'İzin kontrolü hatası: ${e.message}');
			return false;
		}
	}

	/**
	 * İzin isteme - Geliştirilmiş
	 */
	public static function requestPermissions():Void
	{
		try
		{
			if (debugMode)
				trace('[StorageUtil] Requesting permissions...');

			if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
				AndroidPermissions.requestPermissions(['READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO', 'READ_MEDIA_VISUAL_USER_SELECTED']);
			else
				AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

			if (!AndroidEnvironment.isExternalStorageManager())
			{
				if (debugMode)
					trace('[StorageUtil] Requesting storage manager permission...');
				
				AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
			}

			// İzin kontrolü
			var permissionGranted:Bool = false;

			if (AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU)
				permissionGranted = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_MEDIA_IMAGES');
			else
				permissionGranted = AndroidPermissions.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE');

			if (!permissionGranted)
			{
				logError('requestPermissions', 'İzinler verilmedi!');
				CoolUtil.showPopUp(
					Language.getPhrase('permissions_message', 
						'İzinleri kabul ettiyseniz, her şey yolunda demektir!\n' +
						'Kabul etmediyseniz, Oyun Açılmayacaktır!\n' +
						'Lütfen Uygulamanın izinler bölümünden tüm izinleri verin.'),
					Language.getPhrase('mobile_notice', "DİKKAT!")
				);
			}
			else
			{
				if (debugMode)
					trace('[StorageUtil] Permissions granted successfully');
			}

			// Ana dizin oluşturma
			try
			{
				var storageDir:String = getStorageDirectory();
				if (!FileSystem.exists(storageDir))
				{
					if (debugMode)
						trace('[StorageUtil] Creating main storage directory: $storageDir');
					
					FileSystem.createDirectory(storageDir);
				}

				if (!FileSystem.exists(storageDir))
				{
					throw 'Dizin oluşturuldu ama doğrulanamadı!';
				}
			}
			catch (e:Dynamic)
			{
				logError('requestPermissions', 'Ana dizin oluşturma hatası: ${e.message}');
				CoolUtil.showPopUp(
					Language.getPhrase('create_directory_error', 
						'Dizin Oluşturulamadı! Lütfen Şuraya Klasör Oluşturun\n{1}\n' +
						'Hata: {2}\nDestek için Oyun Yapımcısına Başvurun', 
						[getStorageDirectory(), e.message]),
					Language.getPhrase('mobile_error', "HATA!")
				);
				lime.system.System.exit(1);
			}

			// Mods dizini oluşturma
			try
			{
				var modsDir:String = getExternalStorageDirectory() + 'mods';
				if (!FileSystem.exists(modsDir))
				{
					if (debugMode)
						trace('[StorageUtil] Creating mods directory: $modsDir');
					
					FileSystem.createDirectory(modsDir);
				}

				if (!FileSystem.exists(modsDir))
				{
					throw 'Mods dizini oluşturuldu ama doğrulanamadı!';
				}
			}
			catch (e:Dynamic)
			{
				logError('requestPermissions', 'Mods dizini oluşturma hatası: ${e.message}');
				CoolUtil.showPopUp(
					Language.getPhrase('create_directory_error', 
						'Mods Dizini Oluşturulamadı! Lütfen Şuraya Klasör Oluşturun\n{1}\n' +
						'Hata: {2}\nDestek için Oyun Yapımcısına Başvurun', 
						[getExternalStorageDirectory() + 'mods', e.message]),
					Language.getPhrase('mobile_error', "HATA!")
				);
				lime.system.System.exit(1);
			}

			// Saves dizini oluşturma - YENİ
			try
			{
				var savesDir:String = getExternalStorageDirectory() + 'saves';
				if (!FileSystem.exists(savesDir))
				{
					if (debugMode)
						trace('[StorageUtil] Creating saves directory: $savesDir');
					
					FileSystem.createDirectory(savesDir);
				}
			}
			catch (e:Dynamic)
			{
				logError('requestPermissions', 'Saves dizini oluşturma hatası: ${e.message}');
				// Saves dizini kritik değil, sadece log tut
			}

			if (debugMode)
				trace('[StorageUtil] Initialization completed successfully');
		}
		catch (e:Dynamic)
		{
			logError('requestPermissions', 'Kritik hata: ${e.message}');
			CoolUtil.showPopUp(
				'Beklenmeyen bir hata oluştu!\n${e.message}\nOyun kapatılacak...',
				'KRİTİK HATA!'
			);
			lime.system.System.exit(1);
		}
	}

	/**
	 * Depolama alanı bilgisi - YENİ
	 */
	public static function getStorageInfo():String
	{
		try
		{
			var info:String = '=== Depolama Bilgisi ===\n';
			info += 'Ana Dizin: ${getStorageDirectory()}\n';
			info += 'Harici Dizin: ${getExternalStorageDirectory()}\n';
			info += 'İzinler: ${checkPermissions() ? "TAMAM" : "EKSİK"}\n';
			info += 'Android SDK: ${AndroidVersion.SDK_INT}\n';
			info += 'Storage Manager: ${AndroidEnvironment.isExternalStorageManager() ? "AKTİF" : "İNAKTİF"}\n';
			
			// Dizin kontrolü
			info += '\nDizin Durumu:\n';
			info += '- Ana: ${FileSystem.exists(getStorageDirectory()) ? "VAR" : "YOK"}\n';
			info += '- Mods: ${FileSystem.exists(getExternalStorageDirectory() + "mods") ? "VAR" : "YOK"}\n';
			info += '- Saves: ${FileSystem.exists(getExternalStorageDirectory() + "saves") ? "VAR" : "YOK"}\n';

			return info;
		}
		catch (e:Dynamic)
		{
			return 'Bilgi alınamadı: ${e.message}';
		}
	}
	#end
	#end
}