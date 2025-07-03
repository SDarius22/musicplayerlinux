#include "my_application.h"
#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
// #include <thread>
// #include <taglib/fileref.h>
// #include <taglib/tag.h>
// #include <taglib/mpegfile.h>
// #include <taglib/id3v2tag.h>
// #include <taglib/id3v2frame.h>
// #include <taglib/attachedpictureframe.h>
// #include <taglib/flacfile.h>
// #include <taglib/xiphcomment.h>


#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <string>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  // FlMethodChannel* test_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// static const std::string base64_chars =
//     "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
//     "abcdefghijklmnopqrstuvwxyz"
//     "0123456789+/";
//
// std::string base64_encode(const unsigned char* bytes_to_encode, size_t in_len) {
//   std::string ret;
//   int i = 0;
//   int j = 0;
//   unsigned char char_array_3[3];
//   unsigned char char_array_4[4];
//
//   while (in_len--) {
//     char_array_3[i++] = *(bytes_to_encode++);
//     if (i == 3) {
//       char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
//       char_array_4[1] = ((char_array_3[0] & 0x03) << 4) +
//                         ((char_array_3[1] & 0xf0) >> 4);
//       char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) +
//                         ((char_array_3[2] & 0xc0) >> 6);
//       char_array_4[3] = char_array_3[2] & 0x3f;
//
//       for (i = 0; i < 4; i++) ret += base64_chars[char_array_4[i]];
//       i = 0;
//     }
//   }
//
//   if (i) {
//     for (j = i; j < 3; j++) char_array_3[j] = '\0';
//
//     char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
//     char_array_4[1] = ((char_array_3[0] & 0x03) << 4) +
//                       ((char_array_3[1] & 0xf0) >> 4);
//     char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) +
//                       ((char_array_3[2] & 0xc0) >> 6);
//     char_array_4[3] = char_array_3[2] & 0x3f;
//
//     for (j = 0; j < i + 1; j++) ret += base64_chars[char_array_4[j]];
//     while ((i++ < 3)) ret += '=';
//   }
//
//   return ret;
// }
//
//
// FlValue* get_tags_from_file(const std::string& filepath) {
//   TagLib::FileRef f(filepath.c_str());
//   if (f.isNull() || !f.tag()) return nullptr;
//
//   FlValue* result = fl_value_new_map();
//   TagLib::Tag* tag = f.tag();
//
//   fl_value_set(result, fl_value_new_string("title"), fl_value_new_string(tag->title().to8Bit(true).c_str()));
//   fl_value_set(result, fl_value_new_string("trackArtist"), fl_value_new_string(tag->artist().to8Bit(true).c_str()));
//   fl_value_set(result, fl_value_new_string("album"), fl_value_new_string(tag->album().to8Bit(true).c_str()));
//   fl_value_set(result, fl_value_new_string("year"), fl_value_new_int(tag->year()));
//   fl_value_set(result, fl_value_new_string("genre"), fl_value_new_string(tag->genre().to8Bit(true).c_str()));
//   fl_value_set(result, fl_value_new_string("trackNumber"), fl_value_new_int(tag->track()));
//
//   if (f.audioProperties()) {
//     fl_value_set(result, fl_value_new_string("duration"), fl_value_new_int(f.audioProperties()->lengthInSeconds()));
//   }
//
//   // Try to get album artist and picture (MP3)
//   TagLib::MPEG::File mp3file(filepath.c_str());
//   if (mp3file.isValid()) {
//     auto* id3v2tag = mp3file.ID3v2Tag();
//     if (id3v2tag) {
//       auto albumArtistFrames = id3v2tag->frameListMap()["TPE2"];
//       if (!albumArtistFrames.isEmpty()) {
//         fl_value_set(result, fl_value_new_string("albumArtist"),
//                      fl_value_new_string(albumArtistFrames.front()->toString().to8Bit(true).c_str()));
//       }
//
//       auto picFrames = id3v2tag->frameList("APIC");
//       if (!picFrames.isEmpty()) {
//         auto* pic = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame*>(picFrames.front());
//         if (pic) {
//           const auto& data = pic->picture();
//           std::string base64 = base64_encode(reinterpret_cast<const unsigned char*>(data.data()), data.size());
//           fl_value_set(result, fl_value_new_string("picture"), fl_value_new_string(base64.c_str()));
//         }
//       }
//
//       auto discFrames = id3v2tag->frameListMap()["TPOS"];
//       if (!discFrames.isEmpty()) {
//         std::string discStr = discFrames.front()->toString().to8Bit(true).c_str();
//         try {
//           int disc = std::stoi(discStr);
//           fl_value_set(result, fl_value_new_string("discNumber"), fl_value_new_int(disc));
//         } catch (...) {
//           // Ignore parse errors
//         }
//       }
//     }
//   }
//
//   // Try to get album artist and picture (FLAC)
//   TagLib::FLAC::File flacFile(filepath.c_str());
//   if (flacFile.isValid()) {
//     auto* xiph = flacFile.xiphComment();
//     if (xiph) {
//       if (xiph->contains("ALBUMARTIST")) {
//         fl_value_set(result, fl_value_new_string("albumArtist"),
//                      fl_value_new_string(xiph->fieldListMap()["ALBUMARTIST"].toString().to8Bit(true).c_str()));
//       }
//       if (xiph->contains("DISCNUMBER")) {
//         std::string discStr = xiph->fieldListMap()["DISCNUMBER"].toString().to8Bit(true).c_str();
//         try {
//           int disc = std::stoi(discStr);
//           fl_value_set(result, fl_value_new_string("discNumber"), fl_value_new_int(disc));
//         } catch (...) {
//           // Ignore parse errors
//         }
//       }
//     }
//
//     auto picList = flacFile.pictureList();
//     if (!picList.isEmpty()) {
//       auto* pic = picList.front();
//       if (pic) {
//         const auto& data = pic->data();
//         std::string base64 = base64_encode(reinterpret_cast<const unsigned char*>(data.data()), data.size());
//         fl_value_set(result, fl_value_new_string("picture"), fl_value_new_string(base64.c_str()));
//       }
//     }
//   }
//
//   return result;
// }
//
// static void run_get_tags_from_file(FlMethodChannel* channel, const std::string& filepath) {
//   std::thread([filepath, channel]() {
//     FlValue* result = get_tags_from_file(filepath);
//
//     // Pass result back to Flutter on the main thread
//     g_idle_add_full(G_PRIORITY_DEFAULT, [](gpointer data) -> gboolean {
//       auto [channel_ptr, result_ptr] = *static_cast<std::pair<FlMethodChannel*, FlValue*>*>(data);
//       fl_method_channel_invoke_method(channel_ptr, "onTagResult", result_ptr, nullptr, nullptr, nullptr);
//
//       delete static_cast<std::pair<FlMethodChannel*, FlValue*>*>(data);
//       return G_SOURCE_REMOVE;
//     }, new std::pair(channel, result), nullptr);
//   }).detach();
// }
//
//
// static void method_call_handler(FlMethodChannel* channel, FlMethodCall* method_call, gpointer user_data) {
//   const char* method = fl_method_call_get_name(method_call);
//
//   if (strcmp(method, "getTagsFromFile") == 0) {
//     FlValue *args = fl_method_call_get_args(method_call);
//     FlValue *path_val = fl_value_lookup_string(args, "path");
//
//     if (!path_val || fl_value_get_type(path_val) != FL_VALUE_TYPE_STRING) {
//       g_autoptr(FlMethodResponse) error_response = FL_METHOD_RESPONSE(
//         fl_method_error_response_new("invalid_args", "Missing 'path'", nullptr));
//       fl_method_call_respond(method_call, error_response, nullptr);
//       return;
//     }
//
//     std::string filepath = fl_value_get_string(path_val);
//     run_get_tags_from_file(channel, filepath);
//
//     g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
//       fl_method_success_response_new(fl_value_new_string("Started tag reading thread")));
//     fl_method_call_respond(method_call, response, nullptr);
//     return;
//   }
//
//   g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
//   fl_method_call_respond(method_call, response, nullptr);
// }

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "musicplayer");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "musicplayer");
  }

  //added for custom frame
  auto bdw = bitsdojo_window_from(window);
  bdw->setCustomFrame(true);


  //gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));
  //gtk_widget_realize(GTK_WIDGET(window));
  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // self->test_channel = fl_method_channel_new(
  //     fl_engine_get_binary_messenger(fl_view_get_engine(view)),
  //     "dev.flutter/test",
  //     FL_METHOD_CODEC(fl_standard_method_codec_new()));
  //
  // fl_method_channel_set_method_call_handler(self->test_channel, method_call_handler, self, nullptr);


  gtk_widget_grab_focus(GTK_WIDGET(view));
}


// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  // g_clear_object(&self->test_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
