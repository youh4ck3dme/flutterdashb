const String googleCloudOwnerEmail = 'u0352652320@gmail.com';

bool hasGoogleCloudAccess(String? email) {
  return email?.trim().toLowerCase() == googleCloudOwnerEmail;
}
