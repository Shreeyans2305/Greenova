import { useState } from "react";
import { Search, Upload, X } from "lucide-react";

export default function SearchInput({ onSearch, onImageUpload }) {
  const [query, setQuery] = useState("");
  const [dragActive, setDragActive] = useState(false);
  const [uploadedImage, setUploadedImage] = useState(null);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (query.trim()) {
      onSearch(query.trim());
    }
  };

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") setDragActive(true);
    else if (e.type === "dragleave") setDragActive(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    const file = e.dataTransfer?.files?.[0];
    if (file && file.type.startsWith("image/")) {
      setUploadedImage(URL.createObjectURL(file));
      onImageUpload?.(file);
    }
  };

  const handleFileInput = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadedImage(URL.createObjectURL(file));
      onImageUpload?.(file);
    }
  };

  const clearImage = () => {
    setUploadedImage(null);
  };

  return (
    <div className="w-full space-y-4">
      {/* Search Bar */}
      <form onSubmit={handleSubmit} className="relative">
        <div className="relative group">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-surface-200/40 group-focus-within:text-primary-400 transition-colors" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search product name, ingredients, or barcode..."
            className="w-full pl-12 pr-4 py-4 bg-surface-800/60 border border-surface-700/50 rounded-2xl text-surface-100 placeholder:text-surface-200/30 focus:outline-none focus:border-primary-500/50 focus:ring-2 focus:ring-primary-500/20 transition-all duration-300 text-base"
          />
          <button
            type="submit"
            className="absolute right-3 top-1/2 -translate-y-1/2 px-5 py-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white rounded-xl text-sm font-medium hover:from-primary-400 hover:to-primary-500 transition-all duration-300 shadow-lg shadow-primary-500/20 hover:shadow-primary-500/40"
          >
            Analyze
          </button>
        </div>
      </form>

      {/* Image Upload Zone */}
      <div
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
        className={`relative border-2 border-dashed rounded-2xl p-6 text-center transition-all duration-300 cursor-pointer ${
          dragActive
            ? "border-primary-400 bg-primary-500/10"
            : "border-surface-700/40 hover:border-primary-500/30 bg-surface-800/30"
        }`}
      >
        {uploadedImage ? (
          <div className="relative inline-block">
            <img src={uploadedImage} alt="Uploaded" className="max-h-32 rounded-xl" />
            <button
              onClick={clearImage}
              className="absolute -top-2 -right-2 w-6 h-6 bg-danger-500 rounded-full flex items-center justify-center text-white hover:bg-danger-400 transition-colors"
            >
              <X className="w-3 h-3" />
            </button>
          </div>
        ) : (
          <label className="cursor-pointer">
            <Upload className="w-8 h-8 text-surface-200/30 mx-auto mb-2" />
            <p className="text-sm text-surface-200/50">
              Drag & drop a product label image, or{" "}
              <span className="text-primary-400 hover:text-primary-300 underline">browse</span>
            </p>
            <p className="text-xs text-surface-200/30 mt-1">JPEG, PNG up to 10MB</p>
            <input
              type="file"
              accept="image/jpeg,image/png"
              onChange={handleFileInput}
              className="hidden"
            />
          </label>
        )}
      </div>
    </div>
  );
}
