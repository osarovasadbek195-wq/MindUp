import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'copilot_screen.dart';

class VideoResourcesScreen extends StatefulWidget {
  const VideoResourcesScreen({super.key});

  @override
  State<VideoResourcesScreen> createState() => _VideoResourcesScreenState();
}

class _VideoResourcesScreenState extends State<VideoResourcesScreen> {
  final YoutubeExplode _yt = YoutubeExplode();
  final TextEditingController _searchController = TextEditingController();
  List<Video> _videos = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Science',
    'Math',
    'History',
    'Programming',
    'Language',
    'Physics'
  ];

  @override
  void dispose() {
    _yt.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVideos(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _videos = [];
    });

    try {
      // Append "educational" or "tutorial" to ensure educational content
      String searchQuery = "$query educational tutorial";
      
      var searchList = await _yt.search.search(searchQuery);
      
      if (mounted) {
        setState(() {
          _videos = searchList.take(20).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching videos: $e')),
        );
      }
    }
  }

  void _openVideoPlayer(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoId: video.id.value, title: video.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Educational Videos', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CopilotScreen()),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        tooltip: 'Ask Copilot',
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for topics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _searchVideos(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onSubmitted: _searchVideos,
            ),
          ),

          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        if (category != 'All') {
                          _searchController.text = category;
                          _searchVideos(category);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Video List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _videos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Search for educational videos',
                              style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openVideoPlayer(video),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Thumbnail
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      color: Colors.grey[200],
                                      image: DecorationImage(
                                        image: NetworkImage(video.thumbnails.highResUrl),
                                        fit: BoxFit.cover,
                                        onError: (_, __) {},
                                      ),
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.2),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                          ),
                                        ),
                                        const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              _formatDuration(video.duration),
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          video.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                video.author,
                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const VideoPlayerScreen({super.key, required this.videoId, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          onReady: () {
            // Player is ready
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pause video and open Copilot
          _controller.pause();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CopilotScreen()),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        tooltip: 'Ask Copilot about this video',
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
