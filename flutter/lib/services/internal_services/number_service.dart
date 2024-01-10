class NumberService {

  static String scaleNumberString(int int) {
    String? scaledString;

    // 100
    if (int < 1000) {scaledString = int.toString();}

    // 1.00K
    else if(int < 10000) {
      scaledString = '${int.toString()[0]}.${int.toString()[1]}${int.toString()[2]}K';
    }

    //10.0K
    else if(int < 100000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}.${int.toString()[2]}K';
    }

    // 100K
    else if(int < 1000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}${int.toString()[2]}K';
    }

    // 1M
    else if(int < 10000000) {
      scaledString = '${int.toString()[0]}.${int.toString()[1]}${int.toString()[2]}M';
    }

    //10M
    else if(int < 100000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}.${int.toString()[2]}M';
    }

    //100M
    else if(int < 1000000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}${int.toString()[2]}M';
    }

    //1B
    else if(int < 10000000000) {
      scaledString = '${int.toString()[0]}.${int.toString()[1]}${int.toString()[2]}B';
    }

    //10B
    else if(int < 100000000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}.${int.toString()[2]}B';
    }

    //100B
    else if(int < 1000000000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}${int.toString()[2]}B';
    }

    //1T
    else if(int < 10000000000000) {
      scaledString = '${int.toString()[0]}.${int.toString()[1]}${int.toString()[2]}T';
    }

    //10T
    else if(int < 100000000000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}.${int.toString()[2]}T';
    }

    //100T
    else if(int < 1000000000000000) {
      scaledString = '${int.toString()[0]}${int.toString()[1]}${int.toString()[2]}T';
    }



    return scaledString ?? '';
  }

  static String timeAgoHandler(DateTime dt) {
    Duration diff = DateTime.now().difference(dt);
    if(diff.inSeconds < 60) {
      return 'Just now';
    }
    else if(diff.inMinutes == 1) {
      return '${diff.inMinutes} minute ago';
    }
    else if(diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    }
    else if(diff.inHours == 1) {
      return '${diff.inHours} hour ago';
    }
    else if(diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    }
    else if(diff.inDays == 1) {
      return '${diff.inDays} day ago';
    }
    else if(diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }

    else if(diff.inDays < 31) {
      int weeks = (diff.inDays / 7).floor();
      if(weeks == 1 ) {
        return'$weeks week ago';
      }
      return'$weeks weeks ago';
    }
    else if(diff.inDays < 365) {
      int months = (diff.inDays / 30).floor();
      if(months == 1) {
        return '$months month ago';
      }
      return '$months months ago';
    }
    else {
      String monthStringHandler(int month) {
        if(month == 1) return 'January';
        if(month == 2) return 'February';
        if(month == 3) return 'March';
        if(month == 4) return 'April';
        if(month == 5) return 'May';
        if(month == 6) return 'June';
        if(month == 7) return 'July';
        if(month == 8) return 'August';
        if(month == 9) return 'September';
        if(month == 10) return 'October';
        if(month == 11) return 'November';
        if(month == 12) return 'December';
        return '';
      }
      return '${monthStringHandler(dt.month)} ${dt.day}, ${dt.year}';
    }
  }
}