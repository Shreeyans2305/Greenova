import { useState } from "react";
import { Search, Upload, X } from "lucide-react";
import useAIText from "../hooks/useAIText";

export default function SearchInput({ onSearch, onImageUpload }) {
  const [query, setQuery] = useState("");
  const [dragActive, setDragActive] = useState(false);
  const [uploadedImage, setUploadedImage] = useState(null);
  const t = useAIText("search");

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
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted/50 group-focus-within:text-accent-emerald transition-colors" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t("placeholder", "Search product name, ingredients, or barcode...")}
            className="w-full pl-12 pr-4 py-4 bg-card-bg/60 border border-text-muted/20 rounded-2xl text-text-main placeholder:text-text-muted/50 focus:outline-none focus:border-accent-emerald/50 focus:ring-2 focus:ring-accent-emerald/20 transition-all duration-300 text-base"
          />
          <button
            type="submit"
            className="absolute right-3 top-1/2 -translate-y-1/2 px-5 py-2 bg-linear-to-r from-accent-emerald to-accent-emerald-dark text-white rounded-xl text-sm font-medium hover:from-accent-emerald-dark hover:to-accent-emerald transition-all duration-300 shadow-lg shadow-accent-emerald/20 hover:shadow-accent-emerald/40"
          >
            {t("button", "Analyze")}
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
            ? "border-accent-emerald bg-accent-emerald/10"
            : "border-text-muted/30 hover:border-accent-emerald/30 bg-card-bg/30"
        }`}
      >
        {uploadedImage ? (
          <div className="relative inline-block">
            <img src={uploadedImage} alt="Uploaded" className="max-h-32 rounded-xl" />
            <button
              onClick={clearImage}
              className="absolute -top-2 -right-2 w-6 h-6 bg-score-f rounded-full flex items-center justify-center text-white hover:opacity-80 transition-colors"
            >
              <X className="w-3 h-3" />
            </button>
          </div>
        ) : (
          <label className="cursor-pointer">
            <Upload className="w-8 h-8 text-text-muted/30 mx-auto mb-2" />
            <p className="text-sm text-text-muted">
              {t("upload_text", "Drag & drop a product label image, or")}{" "}
              <span className="text-accent-emerald hover:text-accent-emerald-dark underline">{t("browse", "browse")}</span>
            </p>
            <p className="text-xs text-text-muted/50 mt-1">{t("upload_hint", "JPEG, PNG up to 10MB")}</p>
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
